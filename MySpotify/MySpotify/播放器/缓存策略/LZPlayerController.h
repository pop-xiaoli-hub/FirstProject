//
//  PlayerController.h
//  MySpotify
//
//  Created by xiaoli pop on 2026/2/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LZPlayerController : NSObject
+ (instancetype)sharedPlayer;
- (void)playWithURL:(NSURL *)url;
@end

NS_ASSUME_NONNULL_END
