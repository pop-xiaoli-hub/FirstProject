//
//  LZCacheRange.m
//  MySpotify
//
//  Created by xiaoli pop on 2026/2/25.
//
#import "LZCacheIndex.h"
#import "LZCacheRange.h"
@interface LZCacheIndex ()
@property (nonatomic, strong) NSMutableDictionary<NSString*, NSMutableArray<LZCacheRange*>*>* map;
@property (nonatomic, strong) NSMutableDictionary<NSString*, NSNumber*>* totalMap;
@property (nonatomic, strong) NSMutableDictionary<NSString*, dispatch_queue_t>* lockMap;
@property (nonatomic, strong) dispatch_queue_t globalLock;
@property (nonatomic, strong) NSMutableDictionary<NSString*, NSMutableArray<LZCacheRange*>*>* loadingMap;
@end

@implementation LZCacheIndex

+ (instancetype)shared {
  NSLog(@"当前执行：%s",__func__);
  static LZCacheIndex *i;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    i = [LZCacheIndex new];
    i.map = [NSMutableDictionary dictionary];
    i.totalMap = [NSMutableDictionary dictionary];
    i.lockMap = [NSMutableDictionary dictionary];
    i.loadingMap = [NSMutableDictionary dictionary];
    i.globalLock = dispatch_queue_create("com.lz.cacheindex.globallock", DISPATCH_QUEUE_SERIAL);
  });
  return i;
}

- (dispatch_queue_t)queueForKey:(NSString *)key {
  NSLog(@"当前执行：%s",__func__);
  __block dispatch_queue_t q;
  dispatch_sync(self.globalLock, ^{
    q = self.lockMap[key];
    if (!q) {
      q = dispatch_queue_create([[NSString stringWithFormat:@"com.lz.cacheindex.lock.%@", key] UTF8String], DISPATCH_QUEUE_SERIAL);
      self.lockMap[key] = q;
    }
  });
  return q;
}

- (BOOL)isValidKey:(NSString *)key {
  NSLog(@"当前执行：%s",__func__);
  return (key && key.length > 0);
}

#pragma mark - Loading Range
- (BOOL)isRangeLoadingForKey:(NSString *)key start:(NSUInteger)start length:(NSUInteger)length {
  NSLog(@"当前执行：%s",__func__);
  if (![self isValidKey:key] || length == 0) return NO;
  __block BOOL loading = NO;
  dispatch_queue_t q = [self queueForKey:key];
  dispatch_sync(q, ^{
    NSArray<LZCacheRange*> *loadingRanges = self.loadingMap[key];
    if (!loadingRanges) return;
    NSUInteger end = start + length - 1;
    for (LZCacheRange *r in loadingRanges) {
      if (start <= r.end && end >= r.start) {
        loading = YES; break;
      }
    }
  });
  return loading;
}

- (BOOL)markRangeLoadingForKey:(NSString *)key start:(NSUInteger)start length:(NSUInteger)length {
  NSLog(@"当前执行：%s",__func__);
  if (![self isValidKey:key] || length == 0) return NO;
  __block BOOL canMark = YES;
  dispatch_queue_t q = [self queueForKey:key];
  dispatch_sync(q, ^{
    NSMutableArray<LZCacheRange*> *loadingRanges = self.loadingMap[key];
    if (!loadingRanges) {
      loadingRanges = [NSMutableArray array];
      self.loadingMap[key] = loadingRanges;
    }
    NSUInteger end = start + length - 1;
    for (LZCacheRange *r in loadingRanges) {
      if (start <= r.end && end >= r.start) { canMark = NO; break; }
    }
    if (canMark) {
      LZCacheRange *range = [LZCacheRange new];
      range.start = start;
      range.end = end;
      [loadingRanges addObject:range];
    }
  });
  return canMark;
}

- (void)unmarkRangeLoadingForKey:(NSString *)key start:(NSUInteger)start length:(NSUInteger)length {
  NSLog(@"当前执行：%s",__func__);
  if (![self isValidKey:key] || length == 0) return;
  dispatch_queue_t q = [self queueForKey:key];
  dispatch_async(q, ^{
    NSMutableArray<LZCacheRange*> *loadingRanges = self.loadingMap[key];
    if (!loadingRanges) return;
    NSUInteger end = start + length - 1;
    NSMutableArray *toRemove = [NSMutableArray array];
    for (LZCacheRange *r in loadingRanges) {
      if (r.start == start && r.end == end) [toRemove addObject:r];
    }
    [loadingRanges removeObjectsInArray:toRemove];
    if (loadingRanges.count == 0) [self.loadingMap removeObjectForKey:key];
  });
}

#pragma mark - Cached Range
- (void)addRangeForKey:(NSString *)key start:(NSUInteger)start length:(NSUInteger)length {
  NSLog(@"当前执行：%s",__func__);
  if (![self isValidKey:key] || length == 0) return;
  dispatch_queue_t q = [self queueForKey:key];
  dispatch_async(q, ^{
    NSUInteger end = start + length - 1;
    NSMutableArray *ranges = self.map[key];
    if (!ranges) { ranges = [NSMutableArray array]; self.map[key] = ranges; }
    LZCacheRange *newRange = [LZCacheRange new]; newRange.start = start; newRange.end = end;

    NSMutableArray *toRemove = [NSMutableArray array];
    for (LZCacheRange *r in ranges) {
      if (newRange.start <= r.end + 1 && newRange.end + 1 >= r.start) {
        newRange.start = MIN(newRange.start, r.start);
        newRange.end = MAX(newRange.end, r.end);
        [toRemove addObject:r];
      }
    }
    [ranges removeObjectsInArray:toRemove];
    [ranges addObject:newRange];

    [ranges sortUsingComparator:^NSComparisonResult(LZCacheRange *a, LZCacheRange *b){
      if (a.start < b.start) return NSOrderedAscending;
      if (a.start > b.start) return NSOrderedDescending;
      return NSOrderedSame;
    }];
  });
}

- (void)removeRangeForKey:(NSString *)key start:(NSUInteger)start length:(NSUInteger)length {
  NSLog(@"当前执行：%s",__func__);
  if (![self isValidKey:key] || length == 0) return;
  dispatch_queue_t q = [self queueForKey:key];
  dispatch_async(q, ^{
    NSMutableArray<LZCacheRange*> *ranges = self.map[key];
    if (!ranges) return;
    NSUInteger end = start + length - 1;
    NSMutableArray *toRemove = [NSMutableArray array];
    NSMutableArray *toAdd = [NSMutableArray array];

    for (LZCacheRange *r in ranges) {
      if (start <= r.start && end >= r.end) {
        [toRemove addObject:r];
      } else if (start <= r.start && end < r.end && end >= r.start) {
        r.start = end + 1;
      } else if (start > r.start && start <= r.end && end >= r.end) {
        r.end = start - 1;
      } else if (start > r.start && end < r.end) {
        LZCacheRange *newRange = [LZCacheRange new];
        newRange.start = end + 1;
        newRange.end = r.end;
        r.end = start - 1;
        [toAdd addObject:newRange];
      }
    }

    [ranges removeObjectsInArray:toRemove];
    [ranges addObjectsFromArray:toAdd];
  });
}

- (BOOL)isRangeCachedForKey:(NSString *)key start:(NSUInteger)start length:(NSUInteger)length {
  NSLog(@"当前执行：%s",__func__);
  if (![self isValidKey:key] || length == 0) return YES;
  __block BOOL result = NO;
  dispatch_queue_t q = [self queueForKey:key];
  dispatch_sync(q, ^{
    NSArray *ranges = self.map[key];
    if (!ranges) { result = NO; return; }
    NSUInteger end = start + length - 1;
    for (LZCacheRange *r in ranges) {
      if (start >= r.start && end <= r.end) { result = YES; break; }
    }
  });
  return result;
}

- (NSUInteger)nextMissingOffsetForKey:(NSString *)key {
  NSLog(@"当前执行：%s",__func__);
  if (![self isValidKey:key]) return 0;
  __block NSUInteger pos = 0;
  dispatch_queue_t q = [self queueForKey:key];
  dispatch_sync(q, ^{
    NSArray *ranges = self.map[key];
    if (!ranges || ranges.count == 0) { pos = 0; return; }
    NSArray *sorted = [ranges sortedArrayUsingComparator:^NSComparisonResult(LZCacheRange *a, LZCacheRange *b){
      if (a.start < b.start) return NSOrderedAscending;
      if (a.start > b.start) return NSOrderedDescending;
      return NSOrderedSame;
    }];
    NSUInteger p = 0;
    for (LZCacheRange *r in sorted) {
      if (p < r.start) { pos = p; return; }
      p = MAX(p, r.end + 1);
    }
    pos = p;
  });
  return pos;
}

- (BOOL)isCompletedForKey:(NSString *)key {
  NSLog(@"当前执行：%s",__func__);
  if (![self isValidKey:key]) return NO;
  __block BOOL completed = NO;
  dispatch_queue_t q = [self queueForKey:key];
  dispatch_sync(q, ^{
    NSNumber *total = self.totalMap[key];
    if (!total) { completed = NO; return; }
    // 内联「下一个缺失 offset」计算，避免调用 nextMissingOffsetForKey 导致同一队列 sync 死锁
    NSArray *ranges = self.map[key];
    NSUInteger p = 0;
    if (ranges && ranges.count > 0) {
      NSArray *sorted = [ranges sortedArrayUsingComparator:^NSComparisonResult(LZCacheRange *a, LZCacheRange *b){
        if (a.start < b.start) return NSOrderedAscending;
        if (a.start > b.start) return NSOrderedDescending;
        return NSOrderedSame;
      }];
      for (LZCacheRange *r in sorted) {
        if (p < r.start) break;
        p = MAX(p, r.end + 1);
      }
    }
    completed = (p >= total.unsignedIntegerValue);
  });
  return completed;
}

- (void)setTotalLength:(NSUInteger)length forKey:(NSString *)key {
  NSLog(@"当前执行：%s",__func__);
  if (![self isValidKey:key]) return;
  dispatch_queue_t q = [self queueForKey:key];
  dispatch_async(q, ^{
    self.totalMap[key] = @(length);
  });
}

- (NSNumber *)totalLengthForKey:(NSString *)key {
  NSLog(@"当前执行：%s",__func__);
  if (![self isValidKey:key]) return nil;
  __block NSNumber *val = nil;
  dispatch_queue_t q = [self queueForKey:key];
  dispatch_sync(q, ^{
    val = self.totalMap[key];
  });
  return val;
}

- (NSUInteger)cachedTotalLengthForKey:(NSString *)key {
  if (![self isValidKey:key]) {
    return 0;
  }
  __block NSUInteger total = 0;
  dispatch_queue_t q = [self queueForKey:key];
  dispatch_sync(q, ^{
    NSArray<LZCacheRange *> *ranges = self.map[key];
    if (!ranges || ranges.count == 0) {
      return;
    }
    for (LZCacheRange *r in ranges) {
      total += (r.end - r.start + 1);
    }
  });
  return total;
}

- (void)clearForKey:(NSString *)key {
  NSLog(@"当前执行：%s",__func__);
  if (![self isValidKey:key]) return;
  dispatch_queue_t q = [self queueForKey:key];
  dispatch_async(q, ^{
    [self.map removeObjectForKey:key];
    [self.totalMap removeObjectForKey:key];
  });
}

@end
