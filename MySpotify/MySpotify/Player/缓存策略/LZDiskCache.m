//
//  DiskCache.m
//  MySpotify
//
//  Created by xiaoli pop on 2026/2/24.
//

#import "LZDiskCache.h"
#import "LZCachePathHelper.h"
#import <CommonCrypto/CommonCrypto.h>

@interface LZDiskCache ()
@property(nonatomic,strong) NSString *cacheDir;
@property(nonatomic,strong) dispatch_queue_t ioQueue;
@end

@implementation LZDiskCache

+ (instancetype)sharedInstance {
  static LZDiskCache *instance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[LZDiskCache alloc] init];
  });
  return instance;
}

- (instancetype)init {
  NSLog(@"当前执行：%s",__func__);
  if(self=[super init]) {
    self.cacheDir = [LZCachePathHelper streamCacheDirectory];
    self.ioQueue = dispatch_queue_create("disk.cache.queue", DISPATCH_QUEUE_SERIAL);
  }
  return self;
}

- (NSString *)filePath:(NSString *)key {
  NSLog(@"当前执行：%s",__func__);
  return [self.cacheDir stringByAppendingPathComponent:[self sha256String:key]];
}

- (NSData *)readDataForKey:(NSString *)key offset:(NSUInteger)offset length:(NSUInteger)length {
  NSLog(@"当前执行：%s",__func__);
  NSString *path = [self filePath:key];
  if(![[NSFileManager defaultManager] fileExistsAtPath:path]) return nil;
  
  NSFileHandle *handle = nil;
  @try {
    handle = [NSFileHandle fileHandleForReadingAtPath:path];
    [handle seekToFileOffset:offset];
    return [handle readDataOfLength:length];
  } @catch (NSException *exception) {
    return nil;
  } @finally {
    [handle closeFile];
  }
}

- (void)writeData:(NSData *)data offset:(NSUInteger)offset key:(NSString *)key {
  [self writeData:data offset:offset key:key completion:nil];
}

- (void)writeData:(NSData *)data offset:(NSUInteger)offset key:(NSString *)key completion:(void (^)(void))completion {
  NSLog(@"当前执行：%s",__func__);
  if (!data) {
    return;
  }
  dispatch_async(self.ioQueue, ^{
    NSString *path = [self filePath:key];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
      [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
    }
    /*
     以写入模式打开文件，返回文件句柄，先将写入位置移动到offset，如果重叠会发生覆写
     */
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:path];
    [handle seekToFileOffset:offset];
    [handle writeData:data];
    [handle closeFile];
    if (completion) {
      completion();
    }
  });
}

- (NSString *)sha256String:(NSString *)string {
  NSLog(@"当前执行：%s",__func__);
  if (!string) return nil;
  const char *cStr = [string UTF8String];
  unsigned char digest[CC_SHA256_DIGEST_LENGTH];
  CC_SHA256(cStr, (CC_LONG)strlen(cStr), digest);
  NSMutableString *sha256 = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
  for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++){
    [sha256 appendFormat:@"%02x", digest[i]];
  }
  return sha256;
}

@end
