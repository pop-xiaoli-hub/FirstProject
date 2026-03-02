//
//  MusicPlayerManager.m
//  MySpotify
//
//  Created by xiaoli pop on 2025/12/16.
//

#import "MusicPlayerManager.h"
#import "PlaylistManager.h"
#import "SongPlayingModel.h"
#import "SpotifyService.h"
#import "SongDBModel+WCTTableCoding.h"
#import "SongDBModel.h"
#import "DBManager.h"
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
    [[NSNotificationCenter defaultCenter] addObserver:manager selector:@selector(playerDidFinish:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
  });
  return manager;
}

- (void)playerDidFinish:(NSNotification *)noti {
  NSLog(@" 当前歌曲播放完成");
  PlaylistManager *playlistManager = [PlaylistManager shared];
  if (playlistManager.playlist.count == 0) return;
  // 切到下一首
  NSInteger nextIndex = playlistManager.currentIndex + 1;
  if (nextIndex >= playlistManager.playlist.count) {
    nextIndex = 0; // 播放列表循环
  }

  playlistManager.currentIndex = nextIndex;
  SongPlayingModel* model = playlistManager.playlist[nextIndex];

  if (!model.audioResources || model.audioResources.length == 0 ||[model.audioResources isEqualToString:@"null"]) {
    long songId = model.songId;
    SpotifyService* service = [SpotifyService sharedInstance];
    __weak typeof(self) weakSelf = self;
    [service fetchSongResources:model completion:^(BOOL success) {
      if (success) {
        dispatch_async(dispatch_get_main_queue(), ^{
          SongPlayingModel *current = playlistManager.playlist[playlistManager.currentIndex];
          if (current.songId == songId) {
            if (!model.audioResources) {
              return;
            }
            NSURL *url = [NSURL URLWithString:model.audioResources];
            if (!url) {
              NSLog(@"非法URL: %@", model.audioResources);
              return;
            }
            [weakSelf playWithSong:model];
          }
        });
      }
    }];
  } else {
    //[self playWithURL:[NSURL URLWithString:model.audioResources]];
    [self playWithSong:model];
  }
  // 通知UI更新
  [[NSNotificationCenter defaultCenter] postNotificationName:@"changeSong" object:nil userInfo:@{@"index": @(nextIndex)}];
  // 通知按钮状态为播放态
  [[NSNotificationCenter defaultCenter] postNotificationName:@"pressButton" object:nil userInfo:@{@"isPressed": @(1)}];
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


//- (void)playWithURL:(NSURL *)url {
//  self.currentURL = url;
//  if (!url) {
//    return;
//  }
//  [self stop];
//  AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
//  self.currentItem = item;
//
//  [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
//  [self.player replaceCurrentItemWithPlayerItem:item];
//  self.state = MusicPlayerStateBuffering;
//}

- (void)playWithSong:(SongPlayingModel *)song {
  DBManager* manager = [DBManager shared];
  SongDBModel* songDBModel = [[SongDBModel alloc] init];
  songDBModel.songName = song.name;
  songDBModel.artistName = song.artistName;
  songDBModel.picUrl = song.headerUrl;
  songDBModel.songId = song.songId;
  songDBModel.isCompleted = NO;
  songDBModel.cacheSize = 0;
  songDBModel.totalSize = 0;
  [manager createTable:songDBModel];
  [manager insert:songDBModel];
  NSURL* url = nil;
  if (!song.isDownload) {
    url = [NSURL URLWithString:song.audioResources];
  }
  if (song.isDownload) {
    NSString *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *fullPath = [docDir stringByAppendingPathComponent:song.audioResources]; // 动态生成绝对路径
    url = [NSURL fileURLWithPath:fullPath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath]) {
      NSLog(@"文件存在，可以播放");
    } else {
      NSLog(@"文件不存在，无法播放");
    }
  }
  self.currentURL = url;
  if (!url) {
    return;
  }
  [self stop];
  AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
  self.currentItem = item;

  [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
  [self.player replaceCurrentItemWithPlayerItem:item];
  self.state = MusicPlayerStateBuffering;

  NSLog(@"audioResources = %@", song.audioResources);
  NSLog(@"url = %@", url);
  NSLog(@"isFileURL = %d", url.isFileURL);
  NSLog(@"file exists = %d", [[NSFileManager defaultManager] fileExistsAtPath:url.path]);
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

- (NSURL *)localAudioURL:(NSString *)fileName {
  if (!fileName.length) return nil;
  NSString *doc = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
  NSString *audioDir = [doc stringByAppendingPathComponent:@"audio"];
  NSString *fullPath = [audioDir stringByAppendingPathComponent:fileName];
  if (![[NSFileManager defaultManager] fileExistsAtPath:fullPath]) {
    NSLog(@"❌ 本地文件不存在: %@", fullPath);
    return nil;
  }

  return [NSURL fileURLWithPath:fullPath];
}

@end

