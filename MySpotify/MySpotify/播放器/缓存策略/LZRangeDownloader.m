//
//  RangeDownloader.m
//  MySpotify
//
//  Created by xiaoli pop on 2026/2/24.
//


#import "LZRangeDownloader.h"

@interface LZRangeDownloader ()
@property (nonatomic,strong) NSMutableDictionary<NSString*, NSMutableArray<void(^)(NSData*,NSError*)>*> *callbackPool;
@property (nonatomic,strong) NSMutableDictionary<NSString*, NSURLSessionDataTask*> *taskPool;
@property (nonatomic,strong) NSURLSession *session;
@property (nonatomic,strong) dispatch_queue_t syncQueue;
@end

@implementation LZRangeDownloader

+ (instancetype)sharedLoader {
  NSLog(@"当前执行：%s",__func__);
  static LZRangeDownloader *loader;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    loader = [[LZRangeDownloader alloc] init];
  });
  return loader;
}

- (instancetype)init {
  NSLog(@"当前执行：%s",__func__);
  if (self = [super init]) {
    _taskPool = [NSMutableDictionary dictionary];
    _callbackPool = [NSMutableDictionary dictionary];
    _syncQueue = dispatch_queue_create("range.downloader.sync.queue", DISPATCH_QUEUE_CONCURRENT);
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.HTTPMaximumConnectionsPerHost = 3;
    config.timeoutIntervalForRequest = 30;
    config.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
    _session = [NSURLSession sessionWithConfiguration:config];
  }
  return self;
}

- (void)download:(NSURL *)url offset:(NSUInteger)offset length:(NSUInteger)length completion:(void(^)(NSData*,NSError*))completion {
  NSLog(@"当前执行：%s",__func__);
  if (!url || length == 0) {
    if (completion) completion(nil, [NSError errorWithDomain:@"RangeDownloader" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"invalid url or length"}]);
    return;
  }
  
  NSString *taskID = [NSString stringWithFormat:@"%lu_%lu_%lu", (unsigned long)[url.absoluteString hash], (unsigned long)offset, (unsigned long)length];
  
  dispatch_barrier_async(self.syncQueue, ^{
    NSURLSessionDataTask *existTask = self.taskPool[taskID];
    if (existTask) {
      if (completion) [self.callbackPool[taskID] addObject:completion];
      return;
    }
    
    if (completion) self.callbackPool[taskID] = [NSMutableArray arrayWithObject:completion];
    else self.callbackPool[taskID] = [NSMutableArray array];
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setValue:[NSString stringWithFormat:@"bytes=%lu-%lu", (unsigned long)offset, (unsigned long)(offset+length-1)] forHTTPHeaderField:@"Range"];
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *res, NSError *err){
      dispatch_barrier_async(self.syncQueue, ^{
        NSArray *callbacks = self.callbackPool[taskID];
        for (void(^cb)(NSData*,NSError*) in callbacks) cb(data, err);
        [self.callbackPool removeObjectForKey:taskID];
        [self.taskPool removeObjectForKey:taskID];
      });
    }];
    self.taskPool[taskID] = task;
    [task resume];
  });
}

#pragma mark - Cancel
- (void)cancelWithKey:(NSString *)key offset:(NSUInteger)offset length:(NSUInteger)length {
  NSLog(@"当前执行：%s",__func__);
  NSString *taskID = [NSString stringWithFormat:@"%lu_%lu_%lu", (unsigned long)[key hash], (unsigned long)offset, (unsigned long)length];
  dispatch_barrier_async(self.syncQueue, ^{
    NSURLSessionDataTask *task = self.taskPool[taskID];
    if (task) {
      [task cancel];
      [self.taskPool removeObjectForKey:taskID];
    }
  });
}

- (void)cancelAllForKey:(NSString *)key {
  NSLog(@"当前执行：%s",__func__);
  dispatch_barrier_async(self.syncQueue, ^{
    NSArray *allKeys = self.taskPool.allKeys;
    for (NSString *taskID in allKeys) {
      if ([taskID hasPrefix:[NSString stringWithFormat:@"%lu", (unsigned long)[key hash]]]) {
        NSURLSessionDataTask *task = self.taskPool[taskID];
        [task cancel];
        [self.taskPool removeObjectForKey:taskID];
      }
    }
  });
}

- (void)cancelAll {
  NSLog(@"当前执行：%s",__func__);
  dispatch_barrier_async(self.syncQueue, ^{
    for (NSString *taskID in self.taskPool) [self.taskPool[taskID] cancel];
    [self.taskPool removeAllObjects];
  });
}

@end
