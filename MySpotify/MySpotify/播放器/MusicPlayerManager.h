//
//  MusicPlayerManager.h
//  MySpotify
//
//  Created by xiaoli pop on 2025/12/16.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, MusicPlayerState) {
    MusicPlayerStateStopped,
    MusicPlayerStatePlaying,
    MusicPlayerStatePaused,
    MusicPlayerStateBuffering
};

NS_ASSUME_NONNULL_BEGIN

@interface MusicPlayerManager : NSObject
@property (nonatomic, strong) AVPlayer *player;
+ (instancetype)sharedManager;
- (void)playWithURL:(NSURL *)url;

- (void)play;
- (void)pause;
- (void)stop;
- (void)togglePlayPause;

- (NSTimeInterval)currentTime;
- (NSTimeInterval)duration;
- (void)seekToTime:(NSTimeInterval)time;

@property (nonatomic, assign, readonly) MusicPlayerState state;

@end

NS_ASSUME_NONNULL_END

