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
#import "DBManager.h"
#import "SongDBModel.h"
#import "SongDBModel+WCTTableCoding.h"

@interface LZCacheRouter()
@property LZDiskCache *disk;
@property LZMemoryCache *memory;
@property LZRangeDownloader *downloader;
@property dispatch_queue_t routerQueue;           // 串行队列
@property NSMutableDictionary<NSString*, NSMutableArray<void(^)(NSData*,NSError*)>*> *pendingCallbacks; // 等待回调池，用于合并同一段Range的多个请求
@end

@implementation LZCacheRouter

- (instancetype)init {
  NSLog(@"当前执行：%s",__func__);
  if (self = [super init]) {
    _disk = [LZDiskCache sharedInstance];
    _memory = [LZMemoryCache sharedInstance];
    _downloader = [LZRangeDownloader sharedLoader];
    _routerQueue = dispatch_queue_create("com.lz.cacherouter", DISPATCH_QUEUE_SERIAL); // 串行队列保证所有缓存逻辑绝对顺序执行
    _pendingCallbacks = [NSMutableDictionary dictionary];
  }
  return self;
}

- (void)getDataForKey:(NSString *)key url:(NSURL *)url offset:(NSUInteger)offset length:(NSUInteger)length completion:(void (^)(NSData *, NSError *))completion {
  NSLog(@"当前执行：%s",__func__);
  if (!key || !url) {
    if (completion) {
      completion(nil, [NSError errorWithDomain:@"CacheRouter" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"invalid key or url"}]);
    }
    return;
  }

  dispatch_async(self.routerQueue, ^{
    // 构建任务唯一标识
    NSString *taskKey = [NSString stringWithFormat:@"%@_%lu_%lu", key, (unsigned long)offset, (unsigned long)length];

    //内存缓存
    NSData *memData = [self.memory readDataForKey:key offset:offset length:length];
    if (memData.length == length) {
      NSLog(@"path: 从内存缓存读取");
      dispatch_async(dispatch_get_main_queue(), ^{
        completion(memData, nil);
      });
      return;
    }

    //磁盘缓存
    NSData *diskData = [self.disk readDataForKey:key offset:offset length:length];
    if (diskData.length == length) {
      NSLog(@"path: 从磁盘缓存读取");
      [self.memory writeData:diskData offset:offset key:key];
      [[LZCacheIndex shared] addRangeForKey:key start:offset length:diskData.length];
      [self syncCacheInfoToDBForKey:key];
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
        [callbacks addObject:completion];//请求合并，不重复下载
      }
      return;
    }

    //标记正在下载（防止重复发起）
    BOOL canDownload = [[LZCacheIndex shared] markRangeLoadingForKey:key start:offset length:length];
    if (!canDownload) {
      // 标记失败但 pendingCallbacks 中无记录，可能刚有其他线程标记成功但还未创建 pendingCallbacks
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
      NSLog(@"path: 从网络缓存读取");
      dispatch_async(self.routerQueue, ^{
        // 取出所有等待的回调
        NSArray *waitingCallbacks = self.pendingCallbacks[taskKey];
        [self.pendingCallbacks removeObjectForKey:taskKey];
        [[LZCacheIndex shared] unmarkRangeLoadingForKey:key start:offset length:length];

        if (data.length > 0) {
          // 先写内存与索引，再写盘；写盘完成后再回调，避免下次读盘时数据尚未落盘
          [self.memory writeData:data offset:offset key:key];
          [[LZCacheIndex shared] addRangeForKey:key start:offset length:data.length];
          __weak typeof(self) wself = self;
          [self.disk writeData:data offset:offset key:key completion:^{
            __strong typeof(wself) self = wself;
            if (!self) return;
            // 回调所有等待者（落盘后再执行）
            for (void (^cb)(NSData*, NSError*) in waitingCallbacks) {
              dispatch_async(dispatch_get_main_queue(), ^{
                cb(data, nil);
              });
            }
            // 将路径与已缓存大小同步到 WCDB
            dispatch_async(self.routerQueue, ^{
              [self syncCacheInfoToDBForKey:key];
              if (![[LZCacheIndex shared] isCompletedForKey:key]) {
                NSUInteger next = [[LZCacheIndex shared] nextMissingOffsetForKey:key];
                NSUInteger preLen = 256 * 1024;
                if (![[LZCacheIndex shared] isRangeLoadingForKey:key start:next length:preLen]) {
                  [[LZPreloadManager shared] preloadWithKey:key url:url startOffset:next length:preLen];
                }
              }
            });
          }];
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

/// 将当前 key 的磁盘路径与已缓存大小同步到 WCDB（key 为 songId 字符串，稳定）
- (void)syncCacheInfoToDBForKey:(NSString *)key {
  if (!key.length) return;
  SongDBModel *model = nil;
  long long sid = [key longLongValue];
  if (sid > 0) {
    model = [[DBManager shared] querySongWithSongId:(long)sid];
  }
  if (!model) {
    model = [[DBManager shared] querySongWithURL:key];
  }
  if (!model) return;
  NSString *path = [self.disk filePath:key];
  NSUInteger cached = [[LZCacheIndex shared] cachedTotalLengthForKey:key];
  NSNumber *totalNum = [[LZCacheIndex shared] totalLengthForKey:key];
  long long total = totalNum ? (long long)totalNum.unsignedIntegerValue : 0;
  BOOL completed = (total > 0 && (long long)cached >= total);
  [[DBManager shared] updateSongCacheInfoWithSongId:model.songId filePath:path cacheSize:(long long)cached isCompleted:completed];
}

@end
