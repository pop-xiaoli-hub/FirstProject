//
//  StreamingURLBuilder.h
//  MySpotify
//
//  Created by xiaoli pop on 2026/2/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LZStreamingURLBuilder : NSObject
+ (NSURL *)buildStreamingURL:(NSURL *)url;
+ (NSURL *)realURL:(NSURL *)url;
@end

NS_ASSUME_NONNULL_END
