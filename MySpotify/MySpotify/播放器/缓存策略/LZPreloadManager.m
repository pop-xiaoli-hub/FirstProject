//
//  LZPreloadManager.m
//  MySpotify
//
//  Created by xiaoli pop on 2026/2/24.
//


#import "LZPreloadManager.h"
#import "LZMemoryCache.h"
#import "LZDiskCache.h"
#import "LZRangeDownloader.h"
#import "LZCacheIndex.h"

@interface LZPreloadManager()
@property (nonatomic,strong) LZRangeDownloader *net;
@property (nonatomic,strong) LZDiskCache *disk;
@property (nonatomic,strong) LZMemoryCache *memory;
@property (nonatomic,strong) NSOperationQueue *queue;
@end

@implementation LZPreloadManager

+ (instancetype)shared {
  NSLog(@"当前执行：%s",__func__);
  static LZPreloadManager *manager;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    manager = [[LZPreloadManager alloc] init];
  });
  return manager;
}

- (instancetype)init {
  NSLog(@"当前执行：%s",__func__);
  if (self = [super init]) {
    self.net = [LZRangeDownloader sharedLoader];
    self.disk = [LZDiskCache new];
    self.memory = [LZMemoryCache new];
    self.queue = [[NSOperationQueue alloc] init];
    self.queue.maxConcurrentOperationCount = 2;
    self.queue.qualityOfService = NSQualityOfServiceBackground;
  }
  return self;
}

- (void)preloadWithKey:(NSString *)key url:(NSURL *)url startOffset:(NSUInteger)startOffset length:(NSUInteger)length {
  NSLog(@"当前执行：%s",__func__);
  __weak typeof(self) weakSelf = self;
  NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
    [weakSelf.net download:url offset:startOffset length:length completion:^(NSData *data, NSError *error) {
      if(data && data.length > 0){
        [weakSelf.disk writeData:data offset:startOffset key:key];
        [weakSelf.memory writeData:data offset:startOffset key:key];
        [[LZCacheIndex shared] addRangeForKey:key start:startOffset length:data.length];
      }
    }];
  }];
  [self.queue addOperation:op];
}

- (void)cancelAll {
  [self.queue cancelAllOperations];
}

@end
