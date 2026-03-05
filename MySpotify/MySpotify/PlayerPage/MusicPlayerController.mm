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
#import "songModel.h"
#import "CommentViewController.h"
#import "AlbumModel.h"
#import "LyricLine.h"
#import "MusicSlider.h"
@interface MusicPlayerController ()<UIScrollViewDelegate>
@property (nonatomic, assign) BOOL isDragging;
@end

@implementation MusicPlayerController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.myView = [[MusicPlayerView alloc] initWithFrame:self.view.frame];
  self.myView.userInteractionEnabled = YES;
  [self.view addSubview:self.myView];
  [self.myView.centerPage.switchButton addTarget:self action:@selector(pressButtonOfSwitch:) forControlEvents:UIControlEventTouchUpInside];
  [self.myView.centerPage.previousButton addTarget:self action:@selector(pressButtonOfPrevious:) forControlEvents:UIControlEventTouchUpInside];
  [self.myView.centerPage.nextButton addTarget:self action:@selector(pressButtonOfNext:) forControlEvents:UIControlEventTouchUpInside];

  self.myView.scrollView.delegate = self;
  for (UIGestureRecognizer *gr in self.myView.centerPage.imageView.gestureRecognizers) {
    if ([gr isKindOfClass:[UITapGestureRecognizer class]]) {
      [gr requireGestureRecognizerToFail:self.myView.scrollView.panGestureRecognizer];
      break;
    }
  }
  __weak typeof(self) weakSelf = self;
  self.myView.centerPage.buttonClickBlock = ^(UIButton *button) {
    __strong typeof(weakSelf) strongSelf = weakSelf;
    if (!strongSelf) return;
    if (button.tag == 101) {
      [strongSelf handleDownloadButton:button];
    }
    if (button.tag == 102) {
      NSLog(@"评论区按钮");
      [strongSelf handleCommentsButton:button];
    }
  };

  // 初始化播放
  [self changeToIndex:self.currentIndex];
  //  [self syncPlayButtonState];
  self.myView.centerPage.switchButton.selected = YES;
  self.myView.centerPage.showSongLyrics = ^{
    //获取歌词数据
    [weakSelf fetchLyrics];
  };
  NSDictionary* userInfo = @{
    @"isPressed" : @(self.myView.centerPage.switchButton.selected),
  };
  [[NSNotificationCenter defaultCenter] postNotificationName:@"pressButton" object:nil userInfo:userInfo];

  // 拖动中（手指按下并滑动）
  [self.myView.centerPage.slider addTarget:self action:@selector(sliderTouchDown:) forControlEvents:UIControlEventTouchDown];
  [self.myView.centerPage.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];

  // 拖动结束（手指松开）
  [self.myView.centerPage.slider addTarget:self action:@selector(sliderTouchUp:) forControlEvents:UIControlEventTouchUpInside];
  [self.myView.centerPage.slider addTarget:self action:@selector(sliderTouchUp:) forControlEvents:UIControlEventTouchUpOutside];
  
  __weak MusicPlayerManager *weakManager = [MusicPlayerManager sharedManager];
  self.timeObserver = [weakManager.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.5, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
    __strong typeof(weakSelf) strongSelf = weakSelf;
    if (!strongSelf) return;
    AVPlayerItem *currentItem = weakManager.player.currentItem;
    if (!currentItem) return;
    Float64 current = CMTimeGetSeconds(time);
    Float64 total = CMTimeGetSeconds(currentItem.duration);
    if (total > 0 && !isnan(total)) {
      if (!strongSelf.isDragging) {
        strongSelf.myView.centerPage.slider.value = current / total;
      }
    }
    [strongSelf.myView.centerPage updateCurrentTime:current];
  }];

  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(songDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

# pragma mark - 评论区

- (void)handleCommentsButton:(UIButton* )button {
  PlaylistManager* listManager = [PlaylistManager shared];
  SongPlayingModel* playingModel = listManager.playlist[listManager.currentIndex];
  SongModel* song = [[SongModel alloc] init];
  AlbumModel* album = [AlbumModel new];
  album.picUrl = [playingModel.headerUrl copy];
  song.name = [playingModel.name copy];
  song.id = playingModel.songId;
  song.album = album;
  CommentViewController* vc = [[CommentViewController alloc] init];
  vc.songModel = song;
  //  UINavigationController* nav = self.presentingViewController.navigationController;
  [self presentViewController:vc animated:YES completion:nil];
  vc.modalPresentationStyle = UIModalPresentationFullScreen;
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
      song.localPath = fileURL.lastPathComponent;

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

#pragma mark - 稳定切歌

- (void)changeToIndex:(NSInteger)newIndex {
  if (self.musicPlayList.count == 0) {
    return;
  }
  if (newIndex < 0 || newIndex >= self.musicPlayList.count) {
    newIndex = 0;
  }
  MusicPlayerManager *playerManager = [MusicPlayerManager sharedManager];
  self.currentIndex = newIndex;
  self.myView.centerPage.currentIndex = newIndex;
  self.myView.centerPage.isLoading = NO;
  PlaylistManager *manager = [PlaylistManager shared];
  manager.currentIndex = newIndex;
  [self updateUIForCurrentIndex];
  SongPlayingModel* song = manager.playlist[newIndex];
  NSURL* url = nil;
  if (song.isDownload) {
    NSString *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *fullPath = [docDir stringByAppendingPathComponent:song.audioResources]; // 动态生成绝对路径
    url = [NSURL fileURLWithPath:fullPath];
  } else {
    url = [NSURL URLWithString:song.audioResources];
  }
  BOOL isSameSong = playerManager.currentURL && url && [playerManager.currentURL.absoluteString isEqualToString:url.absoluteString];
  BOOL isPlaying = (playerManager.state == MusicPlayerStatePlaying);
  if (isSameSong && isPlaying) {
    [self syncPlayButtonState];
    return;
  }
  [playerManager stop];
  [self prepareAndPlayCurrentSong];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"playNextSong" object:nil userInfo:@{
    @"isPressed" : @(1)
  }];
}


#pragma mark - 歌词
//
//- (NSArray<LyricLine *> *)lyricLinesForCurrentSong {
//  NSMutableArray<LyricLine *> *lines = [NSMutableArray array];
//  NSArray<NSString *> *placeholders = @[
//    @"这是一首简单的歌", @"没有什么独特", @"试着代入我的心事",
//    @"它那么幼稚", @"像个顽皮的孩子", @"多么可笑的心事",
//    @"只剩我还在坚持", @"谁能看透我的眼睛", @"让我能够不再失明",
//    @"也许在你心里", @"梦着自己的梦", @"也许在你的心",
//    @"藏着最深的秘密", @"也许在我的心", @"会有人在听",
//    @"这一首简单的歌", @"并没有独特", @"好像我那么平凡却又深刻"
//  ];
//  for (NSInteger i = 0; i < placeholders.count; i++) {
//    [lines addObject:[[LyricLine alloc] initWithTime:i * 5.0 text:placeholders[i]]];
//  }
//  return [lines copy];
//}

// 按当前歌曲 songId 拉取歌词，解析后在主线程 setLyricLines + reload + updateCurrentTime，保持当前在歌词页并同步播放进度。
- (void)fetchLyrics {
  SpotifyService* service = [SpotifyService sharedInstance];
  PlaylistManager* listManager = [PlaylistManager shared];
  SongPlayingModel* model = [listManager.playlist objectAtIndex:listManager.currentIndex];
  NSString* key = [NSString stringWithFormat:@"%ld", model.songId];
  __weak typeof(self) weakSelf = self;
  [service fetchSongLyrics:key withCompletion:^(id  _Nonnull responseObject, NSError * _Nonnull error) {
    NSDictionary *lrc = responseObject[@"lrc"];
    NSString *lyricsStr = [lrc isKindOfClass:[NSDictionary class]] ? lrc[@"lyric"] : nil;
    NSArray<LyricLine*>* lyrics = [weakSelf lyricLinesForCurrentSong:lyricsStr];
    dispatch_async(dispatch_get_main_queue(), ^{
      [weakSelf.myView.centerPage setLyricLines:lyrics];
      [weakSelf.myView.centerPage.lyricTableView reloadData];
      NSTimeInterval t = [[MusicPlayerManager sharedManager] currentTime];
      [weakSelf.myView.centerPage updateCurrentTime:t];
    });
  }];
}


// 将 LRC 字符串解析为 LyricLine 数组（按 time 升序）
- (NSArray<LyricLine *> *)lyricLinesForCurrentSong:(NSString *)lyricsStr {
  NSMutableArray<LyricLine *> *linesResult = [NSMutableArray array];
  if (!lyricsStr || lyricsStr.length == 0) {
    [linesResult addObject:[[LyricLine alloc] initWithTime:0 text:@"暂无歌词"]];
    return [linesResult copy];
  }
  NSArray *lines = [lyricsStr componentsSeparatedByString:@"\n"];
  for (NSString *line in lines) {
    if (line.length == 0) {
      continue;
    }
    // 可能存在多个时间标签：[00:12.57][00:15.00]歌词
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\[(\\d{2}:\\d{2}\\.\\d{1,3})\\]" options:0 error:nil];
    NSArray<NSTextCheckingResult *> *matches = [regex matchesInString:line options:0 range:NSMakeRange(0, line.length)];
    if (matches.count == 0) {
      continue;
    }
    // 歌词文本（去掉所有时间标签）
    NSString *lyricText = [regex stringByReplacingMatchesInString:line options:0 range:NSMakeRange(0, line.length) withTemplate:@""];
    for (NSTextCheckingResult *match in matches) {
      NSString *timeStr = [line substringWithRange:[match rangeAtIndex:1]];
      NSArray *components = [timeStr componentsSeparatedByString:@":"];
      if (components.count != 2) {
        continue;
      }
      double minute = [components[0] doubleValue];
      double second = [components[1] doubleValue];
      NSTimeInterval totalTime = minute * 60 + second;
      LyricLine *lyricLine = [[LyricLine alloc] initWithTime:totalTime text:lyricText];
      [linesResult addObject:lyricLine];
    }
  }
  [linesResult sortUsingComparator:^NSComparisonResult(LyricLine *obj1, LyricLine *obj2) {
    if (obj1.time < obj2.time) {
      return NSOrderedAscending;
    } else if (obj1.time > obj2.time) {
      return NSOrderedDescending;
    } else {
      return NSOrderedSame;
    }
  }];
  if (linesResult.count == 0) {
    [linesResult addObject:[[LyricLine alloc] initWithTime:0 text:@"暂无歌词"]];
  }
  return [linesResult copy];
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

  [self.myView.centerPage setLyricLines:nil];
  [self.myView.centerPage resetToCover];

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

#pragma mark - 播放入口

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

  // [[MusicPlayerManager sharedManager] playWithURL:url];
  [[MusicPlayerManager sharedManager] playWithSong:model];
  self.myView.centerPage.switchButton.selected = YES;
}


#pragma mark - 拖动播放
- (void)sliderTouchDown:(MusicSlider* )slider {
  self.isDragging = YES;
}

- (void)sliderValueChanged:(MusicSlider* )slider {

}

- (void)sliderTouchUp:(MusicSlider* )slider {
  MusicPlayerManager* manager = [MusicPlayerManager sharedManager];
  self.isDragging = NO;
  AVPlayerItem* item = manager.player.currentItem;
  if (!item) {
    return;
  }
  Float64 total = CMTimeGetSeconds(item.duration);
  if (total <= 0 || isnan(total)) {
    return;
  }
  Float64 targetSeconds = slider.value * total;
  CMTime targetTime = CMTimeMakeWithSeconds(targetSeconds, NSEC_PER_SEC);
  __weak typeof (self) weakSelf = self;
  [manager.player seekToTime:targetTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
    if (finished) {
      [weakSelf.player play];
    }
  }];
}


@end
