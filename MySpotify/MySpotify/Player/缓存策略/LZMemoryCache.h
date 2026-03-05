//
//  LZMemoryCache.h
//  MySpotify
//
//  Created by xiaoli pop on 2026/2/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LZMemoryCache : NSObject
+ (instancetype)sharedInstance;
- (void)removeAllBlocksForKey:(NSString* )key;
- (BOOL)keyMapHasObjectForKey:(NSString* )key;
- (NSData *)readDataForKey:(NSString *)key offset:(NSUInteger)offset length:(NSUInteger)length;
- (void)writeData:(NSData *)data offset:(NSUInteger)offset key:(NSString *)key;
- (void)clear;
@end

NS_ASSUME_NONNULL_END



