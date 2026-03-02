//
//  LZMemoryCache.m
//  MySpotify
//
//  Created by xiaoli pop on 2026/2/24.
//

#import "LZMemoryCache.h"

@interface LZMemoryCache ()
@property (nonatomic,strong) NSCache *cache;
@end

@implementation LZMemoryCache

- (instancetype)init {
  NSLog(@"当前执行：%s",__func__);
  if(self=[super init]) {
    self.cache = [[NSCache alloc] init];
    self.cache.totalCostLimit = 50 * 1024 * 1024; // 50MB
  }
  return self;
}

// 单块 key
- (NSString *)blockKey:(NSString *)key offset:(NSUInteger)offset {
  NSLog(@"当前执行：%s",__func__);
  return [NSString stringWithFormat:@"%@_%lu", key, (unsigned long)offset];
}

// 读取数据
- (NSData *)readDataForKey:(NSString *)key offset:(NSUInteger)offset length:(NSUInteger)length {
  NSLog(@"当前执行：%s",__func__);
  NSString *k = [self blockKey:key offset:offset];
  return [self.cache objectForKey:k];
}

// 写入数据
- (void)writeData:(NSData *)data offset:(NSUInteger)offset key:(NSString *)key {
  NSLog(@"当前执行：%s",__func__);
  if (!data) return;
  NSString *k = [self blockKey:key offset:offset];
  [self.cache setObject:data forKey:k cost:data.length];
}

- (void)clear {
  NSLog(@"当前执行：%s",__func__);
  [self.cache removeAllObjects];
}

@end
