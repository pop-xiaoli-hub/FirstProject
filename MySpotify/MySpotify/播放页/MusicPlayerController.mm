//
//  MusicPlayerController.m
//  MySpotify
//
//  Created by xiaoli pop on 2025/12/6.
//

#import "MusicPlayerController.h"
#import "MusicPlayerView.h"
#import "MusicPLayerManager.h"
#import "MusicDownloadManager.h"
#import "DBManager.h"
#import "LocalDownloadSongs.h"
#import "LocalDownloadSongs+WCTTableCoding.h"
#import "SongPlayingModel.h"
#import "PlaylistManager.h"
#import "SpotifyService.h"

@interface MusicPlayerController ()<UIScrollViewDelegate>
@property (nonatomic, assign) BOOL isDragging;
@end

@implementation MusicPlayerController

#pragma mark - 生命周期

- (void)viewDidLoad {
  [super viewDidLoad];

  self.myView = [[MusicPlayerView alloc] initWithFrame:self.view.frame];
  self.myView.userInteractionEnabled = YES;
  [self.view addSubview:self.myView];

  [self.myView.centerPage.switchButton addTarget:self action:@selector(pressButtonOfSwitch:) forControlEvents:UIControlEventTouchUpInside];
  [self.myView.centerPage.previousButton addTarget:self action:@selector(pressButtonOfPrevious:) forControlEvents:UIControlEventTouchUpInside];
  [self.myView.centerPage.nextButton addTarget:self action:@selector(pressButtonOfNext:) forControlEvents:UIControlEventTouchUpInside];

  self.myView.scrollView.delegate = self;

  __weak typeof(self) weakSelf = self;
  self.myView.centerPage.buttonClickBlock = ^(UIButton *button) {
    __strong typeof(weakSelf) strongSelf = weakSelf;
    if (!strongSelf) return;
    if (button.tag == 101) {
      [strongSelf handleDownloadButton:button];
    }
  };

  // 初始化播放
  [self changeToIndex:self.currentIndex];
  [self syncPlayButtonState];

  __weak MusicPlayerManager *weakManager = [MusicPlayerManager sharedManager];
  self.timeObserver = [weakManager.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
    __strong typeof(weakSelf) strongSelf = weakSelf;
    if (!strongSelf) return;
    AVPlayerItem *currentItem = weakManager.player.currentItem;
    if (!currentItem) return;

    Float64 current = CMTimeGetSeconds(time);
    Float64 total = CMTimeGetSeconds(currentItem.duration);
    if (total > 0 && !isnan(total)) {
      strongSelf.myView.centerPage.slider.value = current / total;
    }
  }];

  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(songDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];

}

#pragma mark - 播放完成回调

- (void)songDidPlayToEnd:(NSNotification *)notification {
    NSLog(@"当前歌曲播放完成");
    // 自动切到下一首
    dispatch_async(dispatch_get_main_queue(), ^{
        [self handleSwipToNext];
    });
}


- (void)dealloc {
  if (self.timeObserver) {
    [[MusicPlayerManager sharedManager].player removeTimeObserver:self.timeObserver];
    self.timeObserver = nil;
  }
  [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];

  NSLog(@"MusicPlayerController dealloc");
}

#pragma mark - UI

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];

  CGFloat width = CGRectGetWidth(self.myView.bounds);
  CGFloat height = CGRectGetHeight(self.myView.bounds);

  self.myView.scrollView.frame = self.myView.bounds;
  self.myView.scrollView.contentSize = CGSizeMake(width * 3, height);

  self.myView.leftPage.frame   = CGRectMake(0, 0, width, height);
  self.myView.centerPage.frame = CGRectMake(width, 0, width, height);
  self.myView.rightPage.frame  = CGRectMake(width * 2, 0, width, height);

  self.isProgrammaticScroll = YES;
  self.myView.scrollView.contentOffset = CGPointMake(width, 0);
  self.isProgrammaticScroll = NO;
}

#pragma mark - 播放按钮状态同步

- (void)syncPlayButtonState {
  MusicPlayerManager *manager = [MusicPlayerManager sharedManager];
  UIButton *btn = self.myView.centerPage.switchButton;
  btn.selected = (manager.state == MusicPlayerStatePlaying);
}

#pragma mark - 下载

- (void)handleDownloadButton:(UIButton* )button {
  SongPlayingModel* currentSongModel = [self.musicPlayList objectAtIndex:self.currentIndex];
  NSURL *url = [NSURL URLWithString:currentSongModel.audioResources];
  [[MusicDownloadManager sharedManager] downloadSongWithURL:url progress:^(float progress) {
    NSLog(@"下载进度: %.2f%%", progress * 100);
  } completion:^(NSURL *fileURL, NSError *error) {
    if (error) {
      NSLog(@"下载失败: %@", error);
    } else {
      dispatch_async(dispatch_get_main_queue(), ^{
        [button setImage:[UIImage imageNamed:@"dwnloaded.png"] forState:UIControlStateNormal];
      });

      LocalDownloadSongs* song = [[LocalDownloadSongs alloc] init];
      song.songName = [currentSongModel.name copy];
      song.picUrl = [currentSongModel.headerUrl copy];
      song.artistName = [currentSongModel.artistName copy];
      song.songId = currentSongModel.songId;
      song.localPath = fileURL.path;

      DBManager* manager = [DBManager shared];
      [manager createTable:song];
      [manager insert:song];
    }
  }];
}

#pragma mark - 播放控制

- (void)pressButtonOfSwitch:(UIButton* )button {
  MusicPlayerManager* manager = [MusicPlayerManager sharedManager];
  button.selected = !button.selected;

  if (button.selected) {
    [manager play];
  } else {
    [manager pause];
  }

  NSDictionary* userInfo = @{
    @"isPressed" : @(button.selected),
  };
  [[NSNotificationCenter defaultCenter] postNotificationName:@"pressButton" object:nil userInfo:userInfo];
}

#pragma mark - 切歌按钮

- (void)pressButtonOfNext:(UIButton* )button {
  NSInteger next = (self.currentIndex + 1) % self.musicPlayList.count;
  [self changeToIndex:next];
}

- (void)pressButtonOfPrevious:(UIButton* )button {
  NSInteger prev = (self.currentIndex - 1 + self.musicPlayList.count) % self.musicPlayList.count;
  [self changeToIndex:prev];
}

#pragma mark - ScrollView

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
  CGFloat width = CGRectGetWidth(self.myView.bounds);
  CGFloat offsetX = scrollView.contentOffset.x;

  if (offsetX == 0) {
    [self handleSwipToPrevious];
  } else if (offsetX == width * 2) {
    [self handleSwipToNext];
  }

  self.isProgrammaticScroll = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  if (self.isProgrammaticScroll) return;

  CGFloat width = CGRectGetWidth(self.myView.bounds);
  CGFloat offsetX = scrollView.contentOffset.x;

  if (offsetX == 0) {
    [self handleSwipToPrevious];
  } else if (offsetX == width * 2) {
    [self handleSwipToNext];
  }
}

#pragma mark - 切歌入口

- (void)handleSwipToNext {
  NSInteger next = (self.currentIndex + 1) % self.musicPlayList.count;
  [self changeToIndex:next];
}

- (void)handleSwipToPrevious {
  NSInteger prev = (self.currentIndex - 1 + self.musicPlayList.count) % self.musicPlayList.count;
  [self changeToIndex:prev];
}

#pragma mark - 核心逻辑（稳定切歌）

- (void)changeToIndex:(NSInteger)newIndex {
  if (self.musicPlayList.count == 0) {
    return;
  }

  if (newIndex < 0 || newIndex >= self.musicPlayList.count) {
    newIndex = 0;
  }

  MusicPlayerManager *playerManager = [MusicPlayerManager sharedManager];

  NSInteger oldIndex = self.currentIndex;
  self.currentIndex = newIndex;

  PlaylistManager *manager = [PlaylistManager shared];
  manager.currentIndex = newIndex;

  [self updateUIForCurrentIndex];

  // 是否需要重新播放判断
  SongPlayingModel *model = manager.playlist[newIndex];
  NSURL *newURL = [NSURL URLWithString:model.audioResources];

  BOOL isSameSong = playerManager.currentURL && newURL && [playerManager.currentURL.absoluteString isEqualToString:newURL.absoluteString];

  BOOL isPlaying = (playerManager.state == MusicPlayerStatePlaying);

  // 正在播放同一首歌 → 不重播
  if (isSameSong && isPlaying) {
    NSLog(@"同一首歌正在播放，不重播");
    [self syncPlayButtonState];
    return;
  }

  // 不是同一首歌 或 没在播放 → 正常播放
  [playerManager stop];
  [self prepareAndPlayCurrentSong];
}


#pragma mark - 只刷新UI

- (void)updateUIForCurrentIndex {
  NSInteger count = self.musicPlayList.count;
  if (count == 0) {
    return;
  }
  NSInteger prevIndex = (self.currentIndex - 1 + count) % count;
  NSInteger nextIndex = (self.currentIndex + 1) % count;

  SongPlayingModel* prevSongModel = self.musicPlayList[prevIndex];
  SongPlayingModel* currentSongModel = self.musicPlayList[self.currentIndex];
  SongPlayingModel* nextSongModel = self.musicPlayList[nextIndex];

  [self.myView.leftPage configureWithModel:prevSongModel];
  [self.myView.centerPage configureWithModel:currentSongModel];
  [self.myView.rightPage configureWithModel:nextSongModel];

  BOOL isDownloaded = NO;
  [self.myView.centerPage resetControlsWithDownloaded:isDownloaded];

  CGFloat width = CGRectGetWidth(self.myView.scrollView.bounds);
  self.isProgrammaticScroll = YES;
  self.myView.scrollView.contentOffset = CGPointMake(width, 0);
  self.isProgrammaticScroll = NO;

  NSDictionary* userInfo = @{
    @"index" : @(self.currentIndex),
  };
  [[NSNotificationCenter defaultCenter] postNotificationName:@"changeSong" object:nil userInfo:userInfo];
}

#pragma mark - 播放入口（异步安全）

- (void)prepareAndPlayCurrentSong {
  if (self.musicPlayList.count == 0) {
    return;
  }
  PlaylistManager* manager = [PlaylistManager shared];
  SongPlayingModel* model = manager.playlist[self.currentIndex];

  if (!model.audioResources || model.audioResources.length == 0 ||[model.audioResources isEqualToString:@"null"]) {
    long songId = model.songId;
    SpotifyService* service = [SpotifyService sharedInstance];
    __weak typeof(self) weakSelf = self;

    [service fetchSongResources:model completion:^(BOOL success) {
      if (success) {
        dispatch_async(dispatch_get_main_queue(), ^{
          SongPlayingModel *current = manager.playlist[manager.currentIndex];
          if (current.songId == songId) {
            [weakSelf playCurrentSongInternal:model];
          }
        });
      }
    }];
    return;
  }

  [self playCurrentSongInternal:model];
}

#pragma mark - 真正播放

- (void)playCurrentSongInternal:(SongPlayingModel *)model {
  if (!model.audioResources) return;

  NSURL *url = [NSURL URLWithString:model.audioResources];
  if (!url) {
    NSLog(@"非法URL: %@", model.audioResources);
    return;
  }

  [[MusicPlayerManager sharedManager] playWithURL:url];
  self.myView.centerPage.switchButton.selected = YES;
}

@end
