//
//  LZCacheRange.h
//  MySpotify
//
//  Created by xiaoli pop on 2026/2/25.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN


@interface LZCacheIndex : NSObject

+ (instancetype)shared;

- (BOOL)isRangeLoadingForKey:(NSString *)key start:(NSUInteger)start length:(NSUInteger)length;
- (BOOL)markRangeLoadingForKey:(NSString *)key start:(NSUInteger)start length:(NSUInteger)length;
- (void)unmarkRangeLoadingForKey:(NSString *)key start:(NSUInteger)start length:(NSUInteger)length;

- (void)addRangeForKey:(NSString *)key start:(NSUInteger)start length:(NSUInteger)length;
- (void)removeRangeForKey:(NSString *)key start:(NSUInteger)start length:(NSUInteger)length;
- (BOOL)isRangeCachedForKey:(NSString *)key start:(NSUInteger)start length:(NSUInteger)length;

- (NSUInteger)nextMissingOffsetForKey:(NSString *)key;
- (BOOL)isCompletedForKey:(NSString *)key;

- (void)setTotalLength:(NSUInteger)length forKey:(NSString *)key;
- (NSNumber *)totalLengthForKey:(NSString *)key;

- (void)clearForKey:(NSString *)key;
@end
NS_ASSUME_NONNULL_END
