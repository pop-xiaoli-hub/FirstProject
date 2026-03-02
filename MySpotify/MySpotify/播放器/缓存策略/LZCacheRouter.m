//
//  CacheRouter.m
//  MySpotify
//
//  Created by xiaoli pop on 2026/2/24.
//

#import "LZCacheRouter.h"
#import "LZMemoryCache.h"
#import "LZDiskCache.h"
#import "LZRangeDownloader.h"
#import "LZPreloadManager.h"
#import "LZCacheIndex.h"

@interface LZCacheRouter()
@property LZDiskCache *disk;
@property LZMemoryCache *memory;
@property LZRangeDownloader *downloader;
@property dispatch_queue_t routerQueue;           // 改为串行队列
@property NSMutableDictionary<NSString*, NSMutableArray<void(^)(NSData*,NSError*)>*> *pendingCallbacks; // 等待回调池
@end

@implementation LZCacheRouter

- (instancetype)init {
  NSLog(@"当前执行：%s",__func__);
  if (self = [super init]) {
    _disk = [LZDiskCache new];
    _memory = [LZMemoryCache new];
    _downloader = [LZRangeDownloader sharedLoader];
    _routerQueue = dispatch_queue_create("com.lz.cacherouter", DISPATCH_QUEUE_SERIAL); // 串行队列
    _pendingCallbacks = [NSMutableDictionary dictionary];
  }
  return self;
}

- (void)getDataForKey:(NSString *)key url:(NSURL *)url offset:(NSUInteger)offset length:(NSUInteger)length completion:(void (^)(NSData *, NSError *))completion {
  NSLog(@"当前执行：%s",__func__);
  if (!key || !url) {
    if (completion) completion(nil, [NSError errorWithDomain:@"CacheRouter" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"invalid key or url"}]);
    return;
  }
  
  dispatch_async(self.routerQueue, ^{
    // 构建任务唯一标识
    NSString *taskKey = [NSString stringWithFormat:@"%@_%lu_%lu", key, (unsigned long)offset, (unsigned long)length];
    
    //内存缓存
    NSData *memData = [self.memory readDataForKey:key offset:offset length:length];
    if (memData.length == length) {
      dispatch_async(dispatch_get_main_queue(), ^{
        completion(memData, nil);
      });
      return;
    }
    
    //磁盘缓存
    NSData *diskData = [self.disk readDataForKey:key offset:offset length:length];
    if (diskData.length == length) {
      [self.memory writeData:diskData offset:offset key:key];
      [[LZCacheIndex shared] addRangeForKey:key start:offset length:diskData.length];
      dispatch_async(dispatch_get_main_queue(), ^{
        completion(diskData, nil);
      });
      return;
    }
    
    //检查是否已有相同范围的下载任务正在进行
    NSMutableArray *callbacks = self.pendingCallbacks[taskKey];
    if (callbacks) {
      // 已有任务，将当前回调加入等待列表
      if (completion) {
        [callbacks addObject:completion];
      }
      return;
    }
    
    //标记正在下载（防止重复发起）
    BOOL canDownload = [[LZCacheIndex shared] markRangeLoadingForKey:key start:offset length:length];
    if (!canDownload) {
      // 极罕见情况：标记失败但 pendingCallbacks 中无记录，可能刚有其他线程标记成功但还未创建 pendingCallbacks
      // 延迟后重试
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), self.routerQueue, ^{
        [self getDataForKey:key url:url offset:offset length:length completion:completion];
      });
      return;
    }
    
    //创建回调数组并启动下载
    NSMutableArray *newCallbacks = [NSMutableArray array];
    if (completion) {
      [newCallbacks addObject:completion];
    }
    self.pendingCallbacks[taskKey] = newCallbacks;
    
    [self.downloader download:url offset:offset length:length completion:^(NSData *data, NSError *error) {
      dispatch_async(self.routerQueue, ^{
        // 取出所有等待的回调
        NSArray *waitingCallbacks = self.pendingCallbacks[taskKey];
        [self.pendingCallbacks removeObjectForKey:taskKey];
        [[LZCacheIndex shared] unmarkRangeLoadingForKey:key start:offset length:length];
        
        if (data.length > 0) {
          // 写入缓存
          [self.disk writeData:data offset:offset key:key];
          [self.memory writeData:data offset:offset key:key];
          [[LZCacheIndex shared] addRangeForKey:key start:offset length:data.length];
          
          // 回调所有等待者
          for (void (^cb)(NSData*, NSError*) in waitingCallbacks) {
            dispatch_async(dispatch_get_main_queue(), ^{
              cb(data, nil);
            });
          }
          
          // 智能预加载
          if (![[LZCacheIndex shared] isCompletedForKey:key]) {
            NSUInteger next = [[LZCacheIndex shared] nextMissingOffsetForKey:key];
            NSUInteger preLen = 256 * 1024;
            if (![[LZCacheIndex shared] isRangeLoadingForKey:key start:next length:preLen]) {
              [[LZPreloadManager shared] preloadWithKey:key url:url startOffset:next length:preLen];
            }
          }
          
        } else {
          // 下载失败
          for (void (^cb)(NSData*, NSError*) in waitingCallbacks) {
            dispatch_async(dispatch_get_main_queue(), ^{
              cb(nil, error);
            });
          }
        }
      });
    }];
  });
}

@end
