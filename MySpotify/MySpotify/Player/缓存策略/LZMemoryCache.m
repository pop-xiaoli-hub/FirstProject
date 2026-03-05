//
//  LZMemoryCache.m
//  MySpotify
//
//  Created by xiaoli pop on 2026/2/24.
//

#import "LZMemoryCache.h"

@interface LZMemoryCache ()
@property (nonatomic,strong) NSCache *cache;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableSet *> *keyMap;
@end

@implementation LZMemoryCache

+ (instancetype)sharedInstance {
  static LZMemoryCache *instance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[LZMemoryCache alloc] init];
  });
  return instance;
}

- (instancetype)init {
  NSLog(@"当前执行：%s",__func__);
  if(self = [super init]) {
    self.cache = [[NSCache alloc] init];
    self.keyMap = [NSMutableDictionary dictionary];
    self.cache.totalCostLimit = 100 * 1024 * 1024; // 100MB
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
  if (!data) {
    return;
  }
  NSString *k = [self blockKey:key offset:offset];
  [self.cache setObject:data forKey:k cost:data.length];
  if (!self.keyMap[key]) {
    self.keyMap[key] = [NSMutableSet set];
  }
  [self.keyMap[key] addObject:@(offset)];
}

- (void)clear {
  NSLog(@"当前执行：%s",__func__);
  [self.cache removeAllObjects];
}

- (BOOL)keyMapHasObjectForKey:(NSString* )key {
  if (!self.keyMap[key]) {
    return NO;
  }
  return YES;
}

- (void)removeAllBlocksForKey:(NSString* )key {
  NSSet* offsets = self.keyMap[key];
  for (NSNumber * offset in offsets) {
    NSString* k = [self blockKey:key offset:offset.unsignedIntegerValue];
    [self.cache removeObjectForKey:k];
  }
  [self.keyMap removeObjectForKey:key];
}

@end
