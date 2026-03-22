//
//  MinePageController.m
//  MySpotify
//
//  Created by xiaoli pop on 2025/11/17.
//

#import "MinePageController.h"
#import "CountHeaderCell.h"
#import "MinePageTableViewCell.h"
#import "UserModel.h"
#import "SongModel.h"
#import "MoreViewController.h"
#import "DBManager.h"
#import "ArtistModel.h"
#import "SpotifyService.h"
#import "DownloadViewController.h"
#import "SongDBModel+WCTTableCoding.h"
#import "SongDBModel.h"
#import "MusicPlayerController.h"
#import "PlaylistManager.h"
@interface MinePageController  ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UserModel *user;
@property (nonatomic, strong) NSMutableArray<SongModel *> *songs;
@property (nonatomic, strong) UIBarButtonItem* leftButton;
@property (nonatomic, strong) UIBarButtonItem* rightButton;
@property (nonatomic, strong) NSMutableArray* localSongArray;
@end

@implementation MinePageController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self setupGradientBackground];
  [self setNavigationBarOpaque];
  [self setTabBarBackgroundColor];
  [self setUpNavigationBar];
  [self setupData];
  [self fetchData];
  [self setupTableView];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadSongs:) name:@"reloadSongs" object:nil];
}

- (void)jumpToPlayerViewController {
  MusicPlayerController* vc = [[MusicPlayerController alloc] init];
  PlaylistManager* manager = [PlaylistManager shared];
  vc.musicPlayList = manager.playlist;
  vc.currentIndex = manager.currentIndex;
  vc.isplaying = YES;
  [self presentViewController:vc animated:YES completion:nil];
}


- (void)reloadSongs:(NSNotification *)notification {
  [self fetchData];
  [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)fetchData {
  DBManager *dataManager = [DBManager shared];
  NSArray *array = [dataManager queryAllSongs];
  NSArray *sorted = [array sortedArrayUsingComparator:^NSComparisonResult(SongDBModel *obj1, SongDBModel *obj2) {
    if (obj1.lastPlayTimestamp > obj2.lastPlayTimestamp) {
      return NSOrderedAscending;
    } else if (obj1.lastPlayTimestamp < obj2.lastPlayTimestamp) {
      return NSOrderedDescending;
    } else {
      return NSOrderedSame;
    }
  }];
  self.localSongArray = sorted ? [NSMutableArray arrayWithArray:sorted] : [NSMutableArray array];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:@"reloadSongs" object:nil];
}

- (void)setupGradientBackground {
  CAGradientLayer *gradient = [CAGradientLayer layer];
  gradient.frame = self.view.bounds;
  UIColor *topBlack = [UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1]; // 深灰
  UIColor *bottomBlack = [UIColor blackColor]; // 纯黑
  gradient.colors = @[(id)topBlack.CGColor, (id)bottomBlack.CGColor];
  gradient.locations = @[@0, @1];
  [self.view.layer insertSublayer:gradient atIndex:0];
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
  for (CALayer *layer in self.view.layer.sublayers) {
    if ([layer isKindOfClass:[CAGradientLayer class]]) {
      layer.frame = self.view.bounds;
      break;
    }
  }
}

- (void)setNavigationBarOpaque {
  UINavigationBarAppearance *app = [[UINavigationBarAppearance alloc] init];
  [app configureWithTransparentBackground];
  app.backgroundColor = [UIColor clearColor];
  app.shadowColor = [UIColor clearColor];
  self.navigationController.navigationBar.standardAppearance = app;
  self.navigationController.navigationBar.scrollEdgeAppearance = app;
  self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}


- (void)setTabBarBackgroundColor {
  UITabBarAppearance *tabAppearance = [[UITabBarAppearance alloc] init];
  tabAppearance.backgroundColor = [UIColor blackColor];
  self.tabBarController.tabBar.standardAppearance = tabAppearance;
  self.tabBarController.tabBar.scrollEdgeAppearance = tabAppearance;
}


- (void)setUpNavigationBar {
  self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
  self.leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"a1.png"] style:UIBarButtonItemStylePlain target:self action:@selector(pressLeft)];
  self.rightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"a2.png"] style:UIBarButtonItemStylePlain target:self action:@selector(pressRight)];
  self.navigationItem.leftBarButtonItem = self.leftButton;
  self.navigationItem.rightBarButtonItem = self.rightButton;
  self.leftButton.tintColor = [UIColor whiteColor];
  self.rightButton.tintColor = [UIColor whiteColor];
}

- (void)pressLeft {

}

- (void)pressRight {

}

- (void)handleDownloadButton:(UIButton* )button {
  DownloadViewController* vc = [[DownloadViewController alloc] init];
  vc.hidesBottomBarWhenPushed = YES;
  [self.navigationController pushViewController:vc animated:YES];
}

- (void)handleAddPlaylistTapped {
}



- (void)setupData {
  if (!self.user) self.user = [UserModel new];
  self.user.name = @"Luna";
  self.user.avatar = [UIImage imageNamed:@"header.jpg"];
}

- (void)setupTableView {
  self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.backgroundColor = [UIColor clearColor];
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  self.tableView.showsVerticalScrollIndicator = NO;
  self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAutomatic;
  [self.tableView registerClass:CountHeaderCell.class forCellReuseIdentifier:@"header"];
  [self.tableView registerClass:MinePageTableViewCell.class forCellReuseIdentifier:@"content"];
  [self.view addSubview:self.tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row == 0) {
    return 120;
  }
  CGFloat playlistH = 314;
  NSInteger count = self.localSongArray.count;
  CGFloat listHeight = (CGFloat)(count * 72);
  return playlistH + listHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row == 0) {
    CountHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"header"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell configWithUser:self.user];
    cell.tapAvatarBlock = ^{
      MoreViewController *vc = [MoreViewController new];
      [self.navigationController pushViewController:vc animated:YES];
    };
    return cell;
  } else {
    MinePageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"content"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    __weak typeof(self) weakSelf = self;
    cell.downloadButtonBlock = ^{
      __strong typeof(weakSelf) strongSelf = weakSelf;
      if (strongSelf) [strongSelf handleDownloadButton:nil];
    };
    cell.buttonClickBlock = ^(UIButton *button) {
      __strong typeof(weakSelf) strongSelf = weakSelf;
      if (strongSelf && button.tag == 101) [strongSelf handleDownloadButton:button];
    };
    cell.cacheSongButtonBlock = ^{
      [self jumpToPlayerViewController];
    };
    cell.addPlaylistButtonBlock = ^{
      __strong typeof(weakSelf) strongSelf = weakSelf;
      if (strongSelf) [strongSelf handleAddPlaylistTapped];
    };
    cell.localSongArray = self.localSongArray ?: [NSMutableArray array];
    return cell;
  }
}


@end




/*
 #pragma mark - Navigation

 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

