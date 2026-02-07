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
@interface MusicPlayerController ()<UIScrollViewDelegate>
@property (nonatomic, assign)BOOL isDragging;

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
  self.myView.centerPage.switchButton.selected = self.isplaying;

  __weak typeof(self) weakSelf = self;
  self.myView.centerPage.buttonClickBlock = ^(UIButton *button) {
      __strong typeof(weakSelf) strongSelf = weakSelf;
      if (!strongSelf) return;
      switch (button.tag) {
          case 101:
              NSLog(@"第一个按钮被点击");
              [strongSelf handleDownloadButton:button];
              break;
          case 102:
              NSLog(@"第二个按钮被点击");
            //  [strongSelf handleDownloadButton2];
              break;
          case 103:
              NSLog(@"第三个按钮被点击");
            //  [strongSelf handleDownloadButton3];
              break;
          case 104:
              NSLog(@"第四个按钮被点击");
             // [strongSelf handleDownloadButton4];
              break;
          default:
              break;
      }
  };

  [self updatesMyViewPages];
  __weak MusicPlayerManager *weakManager = [MusicPlayerManager sharedManager];
  self.timeObserver = [weakManager.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
    __strong typeof(weakSelf) strongSelf = weakSelf;
    if (!strongSelf) {
      return;
    }
    AVPlayerItem *currentItem = weakManager.player.currentItem;
    if (!currentItem) {
      return;
    }
    Float64 current = CMTimeGetSeconds(time);
    Float64 total = CMTimeGetSeconds(currentItem.duration);
    if (total > 0 && !isnan(total)) {
      strongSelf.myView.centerPage.slider.value = current / total;
    }
  }];
}

- (void)handleDownloadButton:(UIButton* )button {
  SongPlayingModel* currentSongModel = [self.musicPlayList objectAtIndex:self.currentIndex];
  NSURL *url = [NSURL URLWithString:currentSongModel.audioResources];

  [[MusicDownloadManager sharedManager] downloadSongWithURL:url
      progress:^(float progress) {
          NSLog(@"下载进度: %.2f%%", progress * 100);
      }
      completion:^(NSURL *fileURL, NSError *error) {
          if (error) {
              NSLog(@"下载失败: %@", error);
          } else {
              NSLog(@"下载完成，本地路径: %@", fileURL.path);
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
              // 这里可以把 fileURL.path 保存到数据库或者 model 中
          }
      }
  ];


  NSLog(@"song:%@", currentSongModel.audioResources);
}

- (void)dealloc {
  if (self.timeObserver) {
    [[MusicPlayerManager sharedManager].player removeTimeObserver:self.timeObserver];
    self.timeObserver = nil;
  }
  NSLog(@"MusicPlayerController dealloc");
}


- (void)pressButtonOfNext:(UIButton* )button {
  CGFloat width = CGRectGetWidth(self.myView.bounds);
  NSLog(@"切换到下一首歌");
  self.isProgrammaticScroll = YES;
  [self.myView.scrollView setContentOffset:CGPointMake(width * 2, 0) animated:YES];
  self.isProgrammaticScroll = NO;
}

- (void)pressButtonOfPrevious:(UIButton* )button {
  // CGFloat width = CGRectGetWidth(self.myView.bounds);
  NSLog(@"切换到上一首歌");
  self.isProgrammaticScroll = YES;
  [self.myView.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
  self.isProgrammaticScroll = NO;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
  CGFloat width = CGRectGetWidth(self.myView.bounds);
  CGFloat offsetX = scrollView.contentOffset.x;

  if (offsetX == 0) {
    [self handleSwipToPrevious];
  } else if (offsetX == width * 2) {
    [self handleSwipToNext];
  }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  if(_isProgrammaticScroll) {
    NSLog(@"popopopopop");
    return;
  }
  NSLog(@"ooioioioioioi");
  CGFloat width = CGRectGetWidth(self.myView.bounds);
  CGFloat offsetX = self.myView.scrollView.contentOffset.x;
  if (offsetX == 0) {
    [self handleSwipToPrevious];
  } else if (offsetX == width * 2){
    [self handleSwipToNext];
  }
}

- (void)pressButtonOfSwitch:(UIButton* )button {
  MusicPlayerManager* manager = [MusicPlayerManager sharedManager];
  NSLog(@"第一次进入详细播放页面按钮被触发,按钮状态：%d", button.selected);
  button.selected = !button.selected;
  if (button.selected) {
    //  [self.player play];
    [manager play];
    NSLog(@"开始播放音乐");
  } else {
    //   [self.player pause];
    [manager pause];
    NSLog(@"停止播放音乐");
  }
}

- (void)play {
  [self.player play];
}

- (void)pause {
  [self.player pause];
}


- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
  CGFloat width = CGRectGetWidth(self.myView.bounds);
  CGFloat height = CGRectGetHeight(self.myView.bounds);
  self.myView.scrollView.frame = self.myView.bounds;
  self.myView.scrollView.contentSize = CGSizeMake(width * 3, height);
  self.myView.leftPage.frame = CGRectMake(0, 0, width, height);
  self.myView.centerPage.frame = CGRectMake(width, 0, width, height);
  self.myView.rightPage.frame = CGRectMake(width * 2, 0, width, height);
  self.isProgrammaticScroll = YES;
  self.myView.scrollView.contentOffset = CGPointMake(width, 0);
  self.isProgrammaticScroll = NO;
}

- (void)updatesMyViewPages {

  if (self.musicPlayList.count == 0) {
    return;
  }
  NSLog(@"当前播放列表数量：%ld", _musicPlayList.count);
  NSInteger count = self.musicPlayList.count;

  if (self.currentIndex < 0 || self.currentIndex >= count) {
    self.currentIndex = 0;
  }

  NSInteger prevIndex = (self.currentIndex - 1 + count) % count;
  NSLog(@"前一首歌曲的序号为: %ld", prevIndex);
  NSInteger nextIndex = (self.currentIndex + 1) % count;
  NSLog(@"后一首歌曲的序号为: %ld", nextIndex);
  SongPlayingModel* prevSongModel = self.musicPlayList[prevIndex];
  [self.myView.leftPage configureWithModel:prevSongModel];
  SongPlayingModel* currentSongModel = self.musicPlayList[self.currentIndex];
  [self.myView.centerPage configureWithModel:currentSongModel];
  SongPlayingModel* nextSongModel = self.musicPlayList[nextIndex];
  [self.myView.rightPage configureWithModel:nextSongModel];

//  BOOL isDownloaded = [[NSFileManager defaultManager] fileExistsAtPath:localPath];
  BOOL isDownloaded = NO;
  [self.myView.centerPage resetControlsWithDownloaded:isDownloaded];


  CGFloat width = CGRectGetWidth(self.myView.scrollView.bounds);
  self.isProgrammaticScroll = YES;
  self.myView.scrollView.contentOffset = CGPointMake(width, 0);
  self.isProgrammaticScroll = NO;
}




- (void)handleSwipToNext {
  if (self.musicPlayList.count == 0) {
    return;
  }

  self.currentIndex = (self.currentIndex + 1) % self.musicPlayList.count;
  [self updatesMyViewPages];
}

- (void)handleSwipToPrevious {
  if (self.musicPlayList.count == 0) {
    return;
  }

  self.currentIndex =
  (self.currentIndex - 1 + self.musicPlayList.count) % self.musicPlayList.count;
  [self updatesMyViewPages];
}


/*
 #pragma mark - Navigation

 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
