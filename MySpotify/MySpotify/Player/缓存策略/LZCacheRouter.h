//
//  CacheRouter.h
//  MySpotify
//
//  Created by xiaoli pop on 2026/2/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LZCacheRouter : NSObject
- (void)getDataForKey:(NSString *)key url:(NSURL *)url offset:(NSUInteger)offset length:(NSUInteger)length completion:(void(^)(NSData *data, NSError *error))completion;
@end

NS_ASSUME_NONNULL_END
