//
//  MusicPlayerManager.m
//  MySpotify
//
//  Created by xiaoli pop on 2025/12/16.
//

#import "MusicPlayerManager.h"

@interface MusicPlayerManager ()


@property (nonatomic, strong) AVPlayerItem *currentItem;
@property (nonatomic, assign, readwrite) MusicPlayerState state;

@end

@implementation MusicPlayerManager


+ (instancetype)sharedManager {
  static MusicPlayerManager *manager;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    manager = [[MusicPlayerManager alloc] init];
    [manager setup];
  });
  return manager;
}

/*
 获取iOS对音频硬件的总开关，实现后台播放，激活音频会话
 初始化播放器，设置初始状态为停止
 */
- (void)setup {
  AVAudioSession *session = [AVAudioSession sharedInstance];
  [session setCategory:AVAudioSessionCategoryPlayback error:nil];
  [session setActive:YES error:nil];
  self.player = [[AVPlayer alloc] init];
  self.state = MusicPlayerStateStopped;
}


- (void)playWithURL:(NSURL *)url {
  if (!url) {
    return;
  }
  [self stop];
  AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
  self.currentItem = item;

  [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
  [self.player replaceCurrentItemWithPlayerItem:item];
  self.state = MusicPlayerStateBuffering;
}

- (void)play {
  if (!self.player.currentItem) {
    return;
  }
  [self.player play];
  self.state = MusicPlayerStatePlaying;
}

- (void)pause {
  [self.player pause];
  self.state = MusicPlayerStatePaused;
}

- (void)stop {
  if (self.currentItem) {
    @try {
      [self.currentItem removeObserver:self forKeyPath:@"status"];
    } @catch (NSException *exception) {
      // 防止重复移除导致崩溃
    }
    self.currentItem = nil;
  }

  [self.player pause];
  [self.player replaceCurrentItemWithPlayerItem:nil];
  self.state = MusicPlayerStateStopped;
}

- (void)togglePlayPause {
  if (self.state == MusicPlayerStatePlaying) {
    [self pause];
  } else {
    [self play];
  }
}

- (NSTimeInterval)currentTime {
  CMTime time = self.player.currentTime;
  if (CMTIME_IS_INVALID(time)) {
    return 0;
  }
  return CMTimeGetSeconds(time);
}

- (NSTimeInterval)duration {
  CMTime time = self.player.currentItem.duration;
  if (CMTIME_IS_INVALID(time)) {//一个不存在的时间，就是说还没加载好
    return 0;
  }
  return CMTimeGetSeconds(time);
}

- (void)seekToTime:(NSTimeInterval)time {
  if (!self.player.currentItem) {
    return;
  }
  CMTime seekTime = CMTimeMakeWithSeconds(time, NSEC_PER_SEC);
  [self.player seekToTime:seekTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {

  if ([keyPath isEqualToString:@"status"]) {
    AVPlayerItem *item = (AVPlayerItem *)object;

    if (item.status == AVPlayerItemStatusReadyToPlay) {
      [self play];
    } else if (item.status == AVPlayerItemStatusFailed) {
      self.state = MusicPlayerStateStopped;
    }
  }
}

- (void)dealloc {
  [self stop];
}

@end

