//
//  HomePageController.m
//  MySpotify
//
//  Created by xiaoli pop on 2025/11/11.
//

#import "HomePageController.h"
#import "HomePageView.h"
#import "Masonry.h"
#import "CustomHomePageCell.h"
#import "HomePageViewModel.h"
#import "AVFoundation/AVFoundation.h"
#import "MusicPlayerController.h"
#import <objc/runtime.h>
#import "SongModel.h"
#import "ArtistModel.h"
#import "AlbumModel.h"
#import <SDWebImage.h>
#import "FloatingPlayerView.h"
#import "RecommendedSongsItemModel.h"
#import "MusicPlayerController.h"
#import "MusicPlayerView.h"
#import "DetailMusicPlayerView.h"
#import "MusicPlayerManager.h"
#import "DBManager.h"
#import "CategoryModel.h"
#import "SongListViewController.h"
#import "PopupTransitionDelegate.h"
#import "PopupViewController.h"
#import "SongDBModel.h"
#import "SongDBModel+WCTTableCoding.h"
#import "SpotifyService.h"
#import "SongPlayingModel.h"
#import "PLaylistManager.h"
//@class DetailMusicPlayerView,MusicPlayerView;
@interface CAAnimationGroup (Completion)
@property (nonatomic, copy) void (^completion)(BOOL finished);
@end

@implementation CAAnimationGroup (Completion)

- (void)setCompletion:(void (^)(BOOL))completion {
  objc_setAssociatedObject(self, @selector(completion), completion, OBJC_ASSOCIATION_COPY_NONATOMIC);
  self.delegate = (id<CAAnimationDelegate>)self;
}

- (void (^)(BOOL))completion {
  return objc_getAssociatedObject(self, @selector(completion));
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
  if (self.completion) {
    self.completion(flag);
  }
}

@end



@interface HomePageController ()<UITableViewDelegate, UITableViewDataSource, CAAnimationDelegate, CustomHomePageCellDelegate>
@property (nonatomic, strong)HomePageView* myView;
@property (nonatomic, strong)HomePageViewModel* viewModel;
@property (nonatomic, strong)UISearchBar* searchBar;
@property (nonatomic, strong)UISearchController* searchController;
@property (nonatomic, assign)BOOL buttonOfAllIsSelected;
@property (nonatomic, strong)UIRefreshControl* refreshControl;
@property (nonatomic, strong)UIActivityIndicatorView* activityIndicator;
@property (nonatomic, assign)BOOL flag;
@property (nonatomic, strong)AVPlayer* player;
@property (nonatomic, strong)AVPlayerItem* item;
@property (nonatomic, strong)SongPlayingModel* currentSongModel;
@property (nonatomic, strong)FloatingPlayerView* floatingPlayerView;
//@property (nonatomic, assign)NSInteger currentPlayIndex;
@property (nonatomic, strong)UIAlertController* alertController;
@property (nonatomic, strong) PopupTransitionDelegate *popupDelegate;
//@property (nonatomic, strong)NSMutableArray* playList;
@end

@implementation HomePageController

- (void)viewDidLoad {
  [super viewDidLoad];
  // self.currentPlayIndex = 0;
  self.flag = 0;
  self.buttonOfAllIsSelected = YES;
  //self.playList = [NSMutableArray array];
  self.view.backgroundColor = [UIColor blackColor];
  self.myView = [[HomePageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
  [self.view addSubview:self.myView];
  self.myView.tableView.delegate = self;
  self.viewModel = [[HomePageViewModel alloc] init];
  [self createTableView];
  [self createActivityIndictor];

  if (!self.flag) {
    [self.activityIndicator startAnimating];
    self.myView.tableView.userInteractionEnabled = NO;
    self.flag = 1;
  }

  [self.myView.tableView addSubview:self.activityIndicator];
  self.myView.tableView.refreshControl = self.refreshControl;

  [self.activityIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.myView.mas_top).offset(390);
    make.centerX.equalTo(self.myView);
  }];

  self.floatingPlayerView = [[FloatingPlayerView alloc] initWithFrame:CGRectZero];
  [self.myView addSubview:self.floatingPlayerView];

  [self.floatingPlayerView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.myView).offset(20);
    make.right.equalTo(self.myView).offset(-20);
    make.bottom.equalTo(self.myView).offset(-90);
    make.height.mas_equalTo(60);
  }];
  self.floatingPlayerView.hidden = YES;

  __weak typeof(self) weakSelf = self;
  self.viewModel.researchSong = ^{

  };

  self.viewModel.updateUI = ^{
    NSLog(@"666");
    NSLog(@"===========刷新collectionView========");
    [weakSelf.myView.tableView reloadData];
    [weakSelf.activityIndicator stopAnimating];
    weakSelf.myView.tableView.userInteractionEnabled = YES;
    if (weakSelf.floatingPlayerView.hidden) {
      weakSelf.floatingPlayerView.hidden = NO;
      [weakSelf.floatingPlayerView createPlayerView];
      [weakSelf fetchSongDataFromDataBase];
    }
    //    [UIView animateWithDuration:0.3 animations:^{
    weakSelf.floatingPlayerView.trackHeaderView.userInteractionEnabled = YES;
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:weakSelf action:@selector(jumpToPlayerViewController)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [weakSelf.floatingPlayerView.trackHeaderView addGestureRecognizer:tap];
    [weakSelf.floatingPlayerView.buttonOfPlayerSwitches addTarget:weakSelf action:@selector(pressPlayerSwitches:) forControlEvents:UIControlEventTouchUpInside];
    //      RecommendedSongsItemModel* item = [weakSelf.viewModel.arrayOfSomeRecommendedSongs objectAtIndex:0];
    //      SongModel* songModel = item.song;
    //      AlbumModel* albumModel = songModel.album;
    //      NSLog(@"12345%@", songModel.audioResources);
    //      weakSelf.currentSongModel = songModel;
    //      //weakSelf.myView.trackHeaderView.image = songModel.image;
    //      SDImageResizingTransformer *transformer =
    //      [SDImageResizingTransformer transformerWithSize:CGSizeMake(200, 200) scaleMode:SDImageScaleModeAspectFill];
    //      [weakSelf.floatingPlayerView.trackHeaderView sd_setImageWithURL:[NSURL URLWithString:albumModel.picUrl] placeholderImage:nil options:SDWebImageScaleDownLargeImages context:@{
    //        SDWebImageContextImageTransformer: transformer, SDWebImageContextImageThumbnailPixelSize: @(CGSizeMake(200,200)), SDWebImageContextImageForceDecodePolicy: @(SDImageForceDecodePolicyNever)
    //      }];
    //      weakSelf.floatingPlayerView.trackNameLabel.text = [songModel.name copy];
    //      ArtistModel* artist = [songModel.artists objectAtIndex:0];
    //      weakSelf.floatingPlayerView.trackArtistNameLabel.text = [artist.name copy];
    //    }];
  };
  self.viewModel.endRefreshing = ^{
    [weakSelf.refreshControl endRefreshing];
    [weakSelf.activityIndicator stopAnimating];
    weakSelf.myView.tableView.userInteractionEnabled = YES;
  };
  self.viewModel.researchSong = ^{
    [weakSelf playSong:weakSelf.floatingPlayerView.buttonOfPlayerSwitches];
  };
  [self.viewModel loadHomePageData];
  [self.myView.buttonOfExpand addTarget:self action:@selector(expandMenuOptions:) forControlEvents:UIControlEventTouchUpInside];
  [self.myView.buttonOfSongs addTarget:self action:@selector(pressButtonOfSongs:) forControlEvents:UIControlEventTouchUpInside];
  [self.myView.tableView reloadData];

  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(upDateFloatingView:) name:@"changeSong" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(upDateSwitchButton:) name:@"pressButton" object:nil];

}

- (void)upDateFloatingView:(NSNotification* )notification {
  NSDictionary* dict = notification.userInfo;
  NSInteger index = [dict[@"index"] integerValue];
  PlaylistManager* manager = [PlaylistManager shared];
  manager.currentIndex = index;
  SongPlayingModel* model = manager.playlist[index];
  self.currentSongModel = model;
  self.floatingPlayerView.trackArtistNameLabel.text = [model.artistName copy];
  self.floatingPlayerView.trackNameLabel.text = [model.name copy];
  SDImageResizingTransformer *transformer =
  [SDImageResizingTransformer transformerWithSize:CGSizeMake(200, 200) scaleMode:SDImageScaleModeAspectFill];
  [self.floatingPlayerView.trackHeaderView sd_setImageWithURL:[NSURL URLWithString:model.headerUrl] placeholderImage:nil options:SDWebImageScaleDownLargeImages context:@{
    SDWebImageContextImageTransformer: transformer, SDWebImageContextImageThumbnailPixelSize: @(CGSizeMake(200,200)), SDWebImageContextImageForceDecodePolicy: @(SDImageForceDecodePolicyNever)
  }];
}

- (void)upDateSwitchButton:(NSNotification* )notification {
  NSDictionary* dict = notification.userInfo;
  NSInteger temp = [dict[@"isPressed"] integerValue];
  self.floatingPlayerView.buttonOfPlayerSwitches.selected = temp;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"changeSong" object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:@"pressButton" object:nil];
}



- (void)fetchSongDataFromDataBase {
  DBManager* dbManager = [DBManager shared];
  PlaylistManager* playlistManager = [PlaylistManager shared];
  NSArray* array = [dbManager queryAllSongs];
  for (int i = 0; i < array.count; i++) {
    SongDBModel* dbModel = array[i];
    SongPlayingModel* playingModel = [[SongPlayingModel alloc] initWithSongName:dbModel.songName andArtistName:dbModel.artistName andSongId:dbModel.songId andPicUrl:dbModel.picUrl andMusicSource:@"null" andIsDownloaded:NO];
    [playlistManager.playlist addObject:playingModel];
  }
  self.currentSongModel = [playlistManager.playlist objectAtIndex:playlistManager.currentIndex];
  SDImageResizingTransformer *transformer =
  [SDImageResizingTransformer transformerWithSize:CGSizeMake(200, 200) scaleMode:SDImageScaleModeAspectFill];
  [self.floatingPlayerView.trackHeaderView sd_setImageWithURL:[NSURL URLWithString:self.currentSongModel.headerUrl] placeholderImage:nil options:SDWebImageScaleDownLargeImages context:@{
    SDWebImageContextImageTransformer: transformer, SDWebImageContextImageThumbnailPixelSize: @(CGSizeMake(200,200)), SDWebImageContextImageForceDecodePolicy: @(SDImageForceDecodePolicyNever)
  }];
  self.floatingPlayerView.trackNameLabel.text = [self.currentSongModel.name copy];
  self.floatingPlayerView.trackArtistNameLabel.text = [self.currentSongModel.name copy];
  //  self.playList = [NSMutableArray arrayWithArray:array];
  //  SongDBModel* dbSong = self.playList[self.currentPlayIndex];
  //  SongModel* song = [SongModel new];
  //  song.id = dbSong.songId;
  //  song.name = [dbSong.songName copy];
  //  song.picUrl = [dbSong.picUrl copy];
  //  song.artistName = [dbSong.artistName copy];
  //  [self.viewModel fetchSongData:song];
}

- (void)playSong:(UIButton* )button {
  PlaylistManager* manager = [PlaylistManager shared];
  SongPlayingModel* model = [manager.playlist objectAtIndex:manager.currentIndex];
  NSURL* url = [NSURL URLWithString:model.audioResources];
  MusicPlayerManager* playManager = [MusicPlayerManager sharedManager];
  [playManager playWithURL:url];
}


- (void)jumpToPlayerViewController {
  [UIView animateWithDuration:0.15 animations:^{
    self.floatingPlayerView.blurView.transform = CGAffineTransformMakeScale(1.05, 1.05);
  } completion:^(BOOL finished) {
    [UIView animateWithDuration:0.1 animations:^{
      self.floatingPlayerView.blurView.transform = CGAffineTransformIdentity;
      MusicPlayerController* vc = [[MusicPlayerController alloc] init];
      PlaylistManager* manager = [PlaylistManager shared];
      vc.musicPlayList = manager.playlist;
      vc.currentIndex = manager.currentIndex;
      //      vc.player = self.player;
      //      vc.item = self.item;

      vc.isplaying = self.floatingPlayerView.buttonOfPlayerSwitches.selected;
      //[vc pressButtonOfSwitch:vc.myView.centerPage.switchButton];
      [self presentViewController:vc animated:YES completion:nil];
    }];
  }];
}

- (void)createActivityIndictor {
  self.refreshControl = [UIRefreshControl new];
  [self.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
  self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
  self.activityIndicator.hidesWhenStopped = YES;
  self.activityIndicator.color = [UIColor whiteColor];
}

- (void)createTableView {
  self.myView.tableView.delegate = self;
  self.myView.tableView.dataSource = self;
  [self.myView.tableView registerClass:[CustomHomePageCell class] forCellReuseIdentifier:@"cell01"];
  [self.myView.tableView registerClass:[CustomHomePageCell class] forCellReuseIdentifier:@"cell02"];
  [self.myView.tableView registerClass:[CustomHomePageCell class] forCellReuseIdentifier:@"cell03"];
  [self.myView.tableView registerClass:[CustomHomePageCell class] forCellReuseIdentifier:@"cell04"];
  [self.myView.tableView registerClass:[CustomHomePageCell class] forCellReuseIdentifier:@"cell05"];
  [self.myView.tableView registerClass:[CustomHomePageCell class] forCellReuseIdentifier:@"cell06"];
  [self.myView.tableView registerClass:[CustomHomePageCell class] forCellReuseIdentifier:@"cell07"];
}

- (void)pressPlayerSwitches:(UIButton* )button {
  button.selected = !button.selected;
  PlaylistManager* manager = [PlaylistManager shared];
  SongPlayingModel* model = manager.playlist[manager.currentIndex];
  if ([model.audioResources isEqualToString:@"null"]) {
    [self.viewModel fetchSongData:manager.playlist[manager.currentIndex]];
  } else {
    NSLog(@"当前播放歌曲名称：%@", model.name);
    if (button.selected) {
      [self play];
      NSLog(@"开始播放音乐");
    } else {
      [self pause];
      NSLog(@"停止播放音乐");
    }
  }
}

- (void)refreshData {
  [self.activityIndicator startAnimating];
  self.myView.tableView.userInteractionEnabled = NO;
  [self.viewModel refreshData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row == 0) {
    CustomHomePageCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell01" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.arrayOfRecommendedSongs = self.viewModel.arrayOfSomeRecommendedSongs;
    cell.delegate = self;

    cell.itemSelectedBlock = ^(NSIndexPath * _Nonnull collectionViewIndexPath) {
      RecommendedSongsItemModel* item = [self.viewModel.arrayOfSomeRecommendedSongs objectAtIndex:collectionViewIndexPath.row];
      SongModel* songModel = item.song;
      AlbumModel* albumModel = songModel.album;
      ArtistModel* artistModel = [songModel.artists objectAtIndex:0];
      NSLog(@"歌曲《%@》被选中了", songModel.name);
      NSLog(@"歌曲id：%lld", songModel.id);
      NSLog(@"歌手名：%@", artistModel.name);
      NSLog(@"歌曲专辑封面图url:%@", albumModel.picUrl);
      NSLog(@"歌曲的音频资源:%@",songModel.audioResources);
    };
    [cell.collectionView reloadData];
    return cell;
  } else if (indexPath.row == 1) {
    CustomHomePageCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell02" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.artistsLabel.text = @"Artists";
    cell.artistsLabel.font = [UIFont fontWithName:@"RacketyDEMO" size:40];
    return cell;
  } else if (indexPath.row == 2) {
    CustomHomePageCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell03" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    for (ArtistModel* model in self.viewModel.arrayOfSomeRecommendedArtists) {
      NSLog(@"歌手名%@, 图片url：%@", model.name, model.img1v1Url);
    }
    cell.arrayOfRecommendedArtists = self.viewModel.arrayOfSomeRecommendedArtists;
    for (ArtistModel* model in cell.arrayOfRecommendedArtists) {
      NSLog(@"123歌手名%@, 图片url：%@", model.name, model.img1v1Url);
    }
    return cell;
  } else if (indexPath.row == 3) {
    CustomHomePageCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell04" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.commendLabel.text = @"Albums";
    cell.commendLabel.font = [UIFont fontWithName:@"RacketyDEMO" size:40];
    return cell;
  } else if (indexPath.row == 4) {
    CustomHomePageCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell05" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    // cell.backgroundColor = [UIColor colorWithRed:138/225.0f green:138/225.0f blue:138/225.0f alpha:0.2];
    cell.arrayOfRecommendedAlbums = self.viewModel.arrayOfSomeRecommededAlbums;
    for (AlbumModel* model in cell.arrayOfRecommendedAlbums) {
      NSLog(@"2专辑%@ %@", model.name, model.coverImgUrl);
    }
    cell.delegate = self;
    cell.backgroundColor = [UIColor clearColor];
    return cell;
  } else if (indexPath.row == 5) {
    CustomHomePageCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell06" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.categoryLabel.text = @"Categories";
    cell.categoryLabel.font = [UIFont fontWithName:@"RacketyDEMO" size:40];
    return cell;
  } else {
    CustomHomePageCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell07" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.arrayOfRecommendedCategories = self.viewModel.arrayOfSomeRecommendedCategories;
    return cell;
  }
}


- (void)play {
  MusicPlayerManager* manager = [MusicPlayerManager sharedManager];
  [manager play];
}

- (void)pause {
  // [self.player pause];
  MusicPlayerManager* manager = [MusicPlayerManager sharedManager];
  [manager pause];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row == 0) {
    return 90;
  } else if (indexPath.row == 1) {
    return 50;
  } else if (indexPath.row == 2) {
    return 250;
  } else if (indexPath.row == 3){
    return 60;
  } else if (indexPath.row == 4) {
    return 280;
  } else if (indexPath.row == 5) {
    return 60;
  } else {
    return 200;
  }
}

# pragma 点击歌曲的动画效果
- (void)triggerAnimation:(UICollectionViewCell* )cell withIndexPath:(NSIndexPath* )indexPath {
  UIImageView* animateView = [[UIImageView alloc] initWithImage:[self snapsShotOfView:cell]];
  animateView.frame = [cell.superview convertRect:cell.frame toView:self.myView];
  /*
   这个convert方法的作用就是将控件的位置在显示位置不变的情况下转换为另一个视图的子视图
   */
  [self.myView addSubview:animateView];
  CGPoint endPoint = CGPointMake(self.myView.bounds.size.width / 2, self.myView.bounds.size.height - 120);


  UIBezierPath *path = [UIBezierPath bezierPath];
  CGPoint startPoint = animateView.center;
  [path moveToPoint:startPoint];

  CGPoint controlPoint = CGPointMake(startPoint.x, startPoint.y - 150);
  [path addQuadCurveToPoint:endPoint controlPoint:controlPoint];

  CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
  /*
   关键帧动画类，可以让动画沿着一条 或者多个关键点变化，key用于指定动画作用的属性，position表示动画作用在CAlayer的位置
   layer有两种状态：
   Model Layer：真实图层，也叫逻辑图层，存储图层的实际属性，程序可以立即修改这个层的属性，立即改变他的值，但是不一定立刻在屏幕上看到动画效果
   Presentation Layer：显示图层，也叫可见图层，是动画效果中屏幕显示的图层状态，会动画而连续变化，只是model layer的快照，用于渲染和动画显示，不会修改真实属性
   涉及Core Animation的设计哲学，只修改GPU的显示状态，而不修改CPU存储的真实属性，渲染更快，同时动画只是临时显示，不影响逻辑状态。
   */
  animation.path = path.CGPath;
  animation.duration = 0.8;
  animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];

  CABasicAnimation *scaleAnim = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
  scaleAnim.fromValue = @(1.0);
  scaleAnim.toValue = @(0.2);

  CABasicAnimation *opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
  opacityAnim.fromValue = @(1.0);
  opacityAnim.toValue = @(0.2);

  CAAnimationGroup *group = [CAAnimationGroup animation];
  group.animations = @[animation, scaleAnim, opacityAnim];
  group.duration = 0.8;
  group.removedOnCompletion = NO;
  group.fillMode = kCAFillModeForwards;

  group.completion = ^(BOOL finished){
    [animateView removeFromSuperview];
    animateView.image = nil;//避免一直持有image导致内存占用逐渐变大
    [UIView animateWithDuration:0.15 animations:^{
      self.floatingPlayerView.blurView.transform = CGAffineTransformMakeScale(1.05, 1.05);
    } completion:^(BOOL finished) {
      [UIView animateWithDuration:0.1 animations:^{
        self.floatingPlayerView.blurView.transform = CGAffineTransformIdentity;
      }];
    }];
    //    RecommendedSongsItemModel* item = [self.viewModel.arrayOfSomeRecommendedSongs objectAtIndex:indexPath.row];
    //    SongModel* songModel = item.song;
    //    self.currentSongModel = songModel;
    //    NSURL* url = [NSURL URLWithString:songModel.audioResources];
    ////    self.item = [AVPlayerItem playerItemWithURL:url];
    ////    self.player = [AVPlayer playerWithPlayerItem:self.item];
    //    MusicPlayerManager* manager = [MusicPlayerManager sharedManager];
    //    [manager playWithURL:url];
    //    self.floatingPlayerView.trackNameLabel.text = songModel.name;
    //    ArtistModel* artist = [songModel.artists objectAtIndex:0];
    //    AlbumModel* albumModel = songModel.album;
    //    self.floatingPlayerView.trackArtistNameLabel.text = [artist.name copy];
    //    self.floatingPlayerView.buttonOfPlayerSwitches.selected = NO;
    //    [self pressPlayerSwitches:self.floatingPlayerView.buttonOfPlayerSwitches];
    //    SDImageResizingTransformer *transformer =
    //    [SDImageResizingTransformer transformerWithSize:CGSizeMake(200, 200) scaleMode:SDImageScaleModeAspectFill];
    //    [self.floatingPlayerView.trackHeaderView sd_setImageWithURL:[NSURL URLWithString:albumModel.picUrl] placeholderImage:nil options:SDWebImageScaleDownLargeImages context:@{
    //      SDWebImageContextImageTransformer: transformer, SDWebImageContextImageThumbnailPixelSize: @(CGSizeMake(200,200)), SDWebImageContextImageForceDecodePolicy: @(SDImageForceDecodePolicyNever)
    //    }];
    PlaylistManager* playlistManager = [PlaylistManager shared];
    RecommendedSongsItemModel* item = [self.viewModel.arrayOfSomeRecommendedSongs objectAtIndex:indexPath.row];
    SongModel* song = item.song;
    ArtistModel* artist = [song.artists objectAtIndex:0];
    AlbumModel* album = song.album;
    SongPlayingModel* songModel = [[SongPlayingModel alloc] initWithSongName:song.name andArtistName:artist.name andSongId:song.id andPicUrl:album.picUrl andMusicSource:song.audioResources andIsDownloaded:NO];
    self.currentSongModel = songModel;
    for (int i = 0; i < playlistManager.playlist.count; i++) {
      SongPlayingModel* modelTemp = playlistManager.playlist[i];
      if (modelTemp.songId == songModel.songId) {
        [playlistManager.playlist removeObject:modelTemp];
      }
    }
    NSLog(@"当前序号：%ld", playlistManager.currentIndex);
    [playlistManager.playlist insertObject:songModel atIndex:0];
    NSURL* url = [NSURL URLWithString:songModel.audioResources];
    MusicPlayerManager* manager = [MusicPlayerManager sharedManager];
    [manager playWithURL:url];
    playlistManager.currentIndex = 0;
    self.floatingPlayerView.trackNameLabel.text = songModel.name;
    self.floatingPlayerView.trackArtistNameLabel.text = [songModel.name copy];
    self.floatingPlayerView.buttonOfPlayerSwitches.selected = NO;
    [self pressPlayerSwitches:self.floatingPlayerView.buttonOfPlayerSwitches];
    SDImageResizingTransformer *transformer =
    [SDImageResizingTransformer transformerWithSize:CGSizeMake(200, 200) scaleMode:SDImageScaleModeAspectFill];
    [self.floatingPlayerView.trackHeaderView sd_setImageWithURL:[NSURL URLWithString:songModel.headerUrl] placeholderImage:nil options:SDWebImageScaleDownLargeImages context:@{
      SDWebImageContextImageTransformer: transformer, SDWebImageContextImageThumbnailPixelSize: @(CGSizeMake(200,200)), SDWebImageContextImageForceDecodePolicy: @(SDImageForceDecodePolicyNever)
    }];
  };

  [animateView.layer addAnimation:group forKey:@"animateToPlayer"];
}


- (UIImage* )snapsShotOfView:(UIView* )view {
  UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0);
  [view.layer renderInContext:UIGraphicsGetCurrentContext()];
  UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return image;
}


- (void)homePageCell:(UICollectionViewCell *)cell withReuseIdentifier:(NSString *)reuseIdentifier didSelectIndexPath:(NSIndexPath *)indexPath {
  if ([reuseIdentifier isEqualToString:@"song"]) {
    RecommendedSongsItemModel* item = self.viewModel.arrayOfSomeRecommendedSongs[indexPath.row];
    SongModel* songModel = item.song;
    if (!songModel.audioResources) {
      UIAlertAction* action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:nil];
      self.alertController = [UIAlertController alertControllerWithTitle:@"提醒" message:@"当前歌曲无授权资源" preferredStyle:UIAlertControllerStyleAlert];
      [self.alertController addAction:action];
      [self presentViewController:self.alertController animated:YES completion:^{}];
    }
    //   self.currentPlayIndex = indexPath.row;
    NSLog(@"hello,按钮动画代理方法触发");
    [self triggerAnimation:cell withIndexPath:indexPath];
  } else  if ([reuseIdentifier isEqualToString:@"album"]){
    AlbumModel* album = [self.viewModel.arrayOfSomeRecommededAlbums objectAtIndex:indexPath.row];
    NSLog(@"点击专辑");
    SongListViewController* vc = [[SongListViewController alloc] initWithId:album.id type:SongListTypeAlbum name:@"专辑"];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
  } else {
    NSLog(@"haha");
    PopupViewController *vc = [[PopupViewController alloc] init];
    self.popupDelegate = [[PopupTransitionDelegate alloc] init];
    vc.modalPresentationStyle = UIModalPresentationCustom;
    vc.transitioningDelegate = self.popupDelegate;
    vc.artistModel = [self.viewModel.arrayOfSomeRecommendedArtists objectAtIndex:indexPath.row];
    NSLog(@"歌手图%@",vc.artistModel.picUrl);
    [self presentViewController:vc animated:YES completion:nil];
  }
}




- (void)pressButtonOfSongs:(UIButton* )button {

}

- (void)buttonOfAllIsSelectedorNot{
  if (self.buttonOfAllIsSelected) {
    self.myView.buttonOfAll.backgroundColor = [UIColor colorWithRed:101/225.0f green:214/225.0f blue:112/225.0f alpha:0.8];
    [self.myView.buttonOfAll setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
  } else {
    self.myView.buttonOfAll.backgroundColor = [UIColor colorWithRed:138/225.0f green:138/225.0f blue:138/225.0f alpha:0.8];
    [self.myView.buttonOfAll setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  }
}

- (void)expandMenuOptions:(UIButton* )button {
  [self buttonOfAllIsSelectedorNot];
  button.selected = !button.selected;
  [UIView animateWithDuration:0.3 animations:^{
    if (button.selected) {
      [UIView animateWithDuration:0.1 animations:^{
        [self.myView.buttonOfAll mas_updateConstraints:^(MASConstraintMaker *make) {
          make.left.equalTo(self.myView.buttonOfExpand).offset(50);
        }];
        self.myView.buttonOfAll.alpha = 1;
      }];
      //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{});
      [UIView animateWithDuration:0.1 animations:^{
        [self.myView.buttonOfSongs mas_updateConstraints:^(MASConstraintMaker *make) {
          make.left.equalTo(self.myView.buttonOfExpand).offset(130);
        }];
        self.myView.buttonOfSongs.alpha = 1;
      }];
      [UIView animateWithDuration:0.1 animations:^{
        [self.myView.buttonOfAudioBooks mas_updateConstraints:^(MASConstraintMaker *make) {
          make.left.equalTo(self.myView.buttonOfExpand).offset(210);
        }];
        self.myView.buttonOfAudioBooks.alpha = 1;
      }];
    } else {
      [UIView animateWithDuration:0.1 animations:^{
        [self.myView.buttonOfAll mas_updateConstraints:^(MASConstraintMaker *make) {
          make.left.equalTo(self.myView.buttonOfExpand);
        }];
        self.myView.buttonOfAll.alpha = 0;
      }];

      [UIView animateWithDuration:0.1 animations:^{
        [self.myView.buttonOfSongs mas_updateConstraints:^(MASConstraintMaker *make) {
          make.left.equalTo(self.myView.buttonOfExpand);
        }];
        self.myView.buttonOfSongs.alpha = 0;
      }];
      [UIView animateWithDuration:0.1 animations:^{
        [self.myView.buttonOfAudioBooks mas_updateConstraints:^(MASConstraintMaker *make) {
          make.left.equalTo(self.myView.buttonOfExpand);
        }];
        self.myView.buttonOfAudioBooks.alpha = 0;
      }];
    }
    [self.myView layoutIfNeeded];
  }];

}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self.navigationController setNavigationBarHidden:YES animated:NO];
}

/*
 #pragma mark - Navig√ation

 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
