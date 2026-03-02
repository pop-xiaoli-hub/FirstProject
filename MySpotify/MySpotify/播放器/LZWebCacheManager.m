//
//  WebCacheManager.m
//  MySpotify
//
//  Created by xiaoli pop on 2026/2/24.
//
#import <CommonCrypto/CommonCrypto.h>
#import "LZWebCacheManager.h"
@interface LZWebCacheManager()
@property (nonatomic, strong)dispatch_queue_t ioQueue;
@end

@implementation LZWebCacheManager
//初始化
+ (instancetype)sharedCache {
  static LZWebCacheManager* cache;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    cache = [[LZWebCacheManager alloc] initPrivate];
  });
  return cache;
}

- (instancetype)initPrivate {
  if (self = [super init]) {
    _memoryCache = [[NSCache alloc] init];
    _ioQueue = dispatch_queue_create("com.xiaoli.webCache", DISPATCH_QUEUE_SERIAL);
    NSString* cacheDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    _diskCachePath = [cacheDir stringByAppendingPathComponent:@"webCache"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:_diskCachePath]) {
      [[NSFileManager defaultManager] createDirectoryAtPath:_diskCachePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
  }
  return self;
}

//一级缓存
- (NSData *)dataFromMemoryCacheForKey:(NSString *)key {
  if (!key) {
    return nil;
  }
  return [self.memoryCache objectForKey:key];
}

- (void)storeDataToMemoryCache:(NSData *)data forKey:(NSString *)key {
  if (!data || !key) {
    return;
  }
  [self.memoryCache setObject:data forKey:key];
}

- (void)clearMemoryCache {
  [self.memoryCache removeAllObjects];
}

//二级缓存
- (NSData *)dataFromDiskCacheForKey:(NSString *)key {
  if (!key) {
    return nil;
  }
  NSString* path = [self filePathForKey:key];
  if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
    return nil;
  }
  return  [NSData dataWithContentsOfFile:path];
}

- (void)storeDataToDiskCache:(NSData *)data forKey:(NSString *)key {
  if (!data || !key) {
    return;
  }
  NSString* path = [self filePathForKey:key];
  dispatch_async(self.ioQueue, ^{
    [data writeToFile:path atomically:YES];
  });
}

-(BOOL)diskCacheExistsForKey:(NSString *)key {
  if (!key) {
    return NO;
  }
  NSString* path = [self filePathForKey:key];
  return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

- (void)clearDiskCache {
  dispatch_async(self.ioQueue, ^{
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.diskCachePath]) {
      [[NSFileManager defaultManager] removeItemAtPath:self.diskCachePath error:nil];
      [[NSFileManager defaultManager] createDirectoryAtPath:self.diskCachePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
  });
}

- (void)dataForKey:(NSString *)key remoteURL:(NSURL *)url completion:(WebCacheCompletion)completion {
  if (!key) {
    if (completion) {
      completion(nil, NO, [NSError errorWithDomain:@"WebCache" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"keyisnil"}]);
    }
    return;
  }
  // 1️⃣ 查内存缓存
  NSData *memoryData = [self dataFromMemoryCacheForKey:key];
  if (memoryData) {
    if (completion) completion(memoryData, YES, nil);
    return;
  }
  // 2️⃣ 查磁盘缓存（异步）
  dispatch_async(self.ioQueue, ^{
    NSData *diskData = [self dataFromDiskCacheForKey:key];
    if (diskData) {
      // 写入内存缓存
      [self storeDataToMemoryCache:diskData forKey:key];

      dispatch_async(dispatch_get_main_queue(), ^{
        if (completion) completion(diskData, YES, nil);
      });
      return;
    }

    // 3️⃣ 内存 + 磁盘都没有 → 网络层
    if (!self.service) {
      dispatch_async(dispatch_get_main_queue(), ^{
        if (completion) completion(nil, NO, [NSError errorWithDomain:@"Web三级缓存" code:-2 userInfo:@{NSLocalizedDescriptionKey:@"未注入网络服务"}]);
      });
      return;
    }

    // 调用外部网络模块
//    [self.service fetchDataWithURL:url key:key completion:^(NSData * _Nullable data, NSError * _Nullable error) {
//
//      if (error || !data) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//          if (completion) completion(nil, NO, error);
//        });
//        return;
//      }
//
//      // 网络成功 → 回写缓存
//      [self storeDataToDiskCache:data forKey:key];
//      [self storeDataToMemoryCache:data forKey:key];
//
//      dispatch_async(dispatch_get_main_queue(), ^{
//        if (completion) completion(data, NO, nil);
//      });
//    }];
  });
}

#pragma mark - 通用工具

- (void)storeData:(NSData *)data forKey:(NSString *)key {
  if (!data || !key) return;
  [self storeDataToMemoryCache:data forKey:key];
  [self storeDataToDiskCache:data forKey:key];
}

- (NSString *)cachePathForKey:(NSString *)key {
  return [self filePathForKey:key];
}

- (NSString *)filePathForKey:(NSString *)key {
  NSString *fileName = [self sha256String:key];
  return [self.diskCachePath stringByAppendingPathComponent:fileName];
}

// SHA256 版本
- (NSString *)sha256String:(NSString *)string {
    if (!string) return nil;

    const char *cStr = [string UTF8String];
    unsigned char digest[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(cStr, (CC_LONG)strlen(cStr), digest);

    NSMutableString *sha256 = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [sha256 appendFormat:@"%02x", digest[i]];
    }
    return sha256;
}

- (void)clearAllCache {
  [self clearMemoryCache];
  [self clearDiskCache];
}

@end

//- (NSString *)md5String:(NSString *)string {
//  if (!string) return nil;
//  const char *cStr = [string UTF8String];
//  unsigned char digest[CC_MD5_DIGEST_LENGTH];
//  CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
//
//  NSMutableString *md5 = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
//  for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
//    [md5 appendFormat:@"%02x", digest[i]];
//  }
//  return md5;
//}

