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
@interface MinePageController  ()<UITableViewDelegate,UITableViewDataSource, UIScrollViewDelegate>
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
  [self fetchData];
  [self setNavigationBarOpaque];
  [self setTabBarBackgroundColor];
  UIImage* image =  [UIImage imageNamed:@"back.jpg"];
  self.view.layer.contents = (__bridge id)image.CGImage;
  self.view.backgroundColor = [UIColor clearColor];

//  self.view.backgroundColor = UIColor.systemGroupedBackgroundColor;
  [self setUpNavigationBar];
  [self setupData];
  [self setupTableView];
  // Do any additional setup after loading the view.
}

- (void)fetchData {
  DBManager* dataManager = [DBManager shared];
  NSArray* array = [dataManager queryAllSongs];
  self.localSongArray = [NSMutableArray arrayWithArray:array];
}

- (void)setNavigationBarOpaque {
    UINavigationBarAppearance* app = [[UINavigationBarAppearance alloc] init];
    [app configureWithOpaqueBackground];
    app.shadowColor = [UIColor clearColor];
    app.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.standardAppearance = app;
    self.navigationController.navigationBar.scrollEdgeAppearance =  app;

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
  self.leftButton.tintColor = [UIColor colorWithRed:0.5 green:0.1 blue:0.3 alpha:1];
  self.rightButton.tintColor = [UIColor colorWithRed:0.5 green:0.1 blue:0.3 alpha:1];
}

- (void)pressLeft {
  
}

- (void)pressRight {

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  CGFloat contentx = scrollView.contentOffset.x;
  CGFloat w = scrollView.frame.size.width;
  CGFloat index = contentx / w;
  NSInteger select = (NSInteger)(index + 0.5);
  MinePageTableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
  if (select >= cell.segmentControl.numberOfSegments) {
    select = cell.segmentControl.numberOfSegments - 1;
  }
  if (cell.segmentControl.selectedSegmentIndex != select) {
    cell.segmentControl.selectedSegmentIndex = select;
  }    //self.segmentControl.selectedSegmentIndex = contentx / [[UIScreen mainScreen] bounds].size.width;
}

- (void)segChanged {
  MinePageTableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
  NSInteger selected = cell.segmentControl.selectedSegmentIndex;
  CGFloat offsetx = selected * cell.scrollView.bounds.size.width;
  [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
    cell.scrollView.contentOffset = CGPointMake(offsetx, 0);
  } completion:nil];
}

- (void)handleDownloadButton:(UIButton* )button {
  DownloadViewController* vc = [[DownloadViewController alloc] init];
  vc.hidesBottomBarWhenPushed = YES;
  [self.navigationController pushViewController:vc animated:YES];
}

- (void)setupData {
  self.user = [UserModel new];
  self.user.name = @"情深似海无边际";
  self.user.avatar = [UIImage imageNamed:@"header.jpg"];

  self.songs = @[].mutableCopy;
  NSArray *titles = @[@"我是一只小猪",@"明天我要娶了你",@"今天你要嫁给我"];
  NSArray *authors = @[@"阿土",@"郑燕子",@"孙燕姿"];

  for (int i = 0; i < titles.count; i++) {
    SongModel *s = [SongModel new];
    ArtistModel* artist = [s.artists objectAtIndex:0];
    s.name = titles[i];
    artist.name = authors[i];
    [self.songs addObject:s];
  }
}

- (void)setupTableView {
  self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.backgroundColor = [UIColor clearColor];

  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  [self.tableView registerClass:CountHeaderCell.class forCellReuseIdentifier:@"header"];
  [self.tableView registerClass:MinePageTableViewCell.class forCellReuseIdentifier:@"content"];
  [self.view addSubview:self.tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSInteger count = self.localSongArray.count;
  CGFloat height = 80 * (count + 1);
  return indexPath.row == 0 ? 180 : height + 200;
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
    cell.buttonClickBlock = ^(UIButton * button) {
      __strong typeof(weakSelf) strongSelf = self;
      if (!strongSelf) return;
      switch (button.tag) {
        case 101:
          NSLog(@"第一个按钮被点击");
          [strongSelf handleDownloadButton:button];
          break;
        default:
          break;
      }
    };
    cell.scrollView.delegate = self;
    cell.localSongArray = self.localSongArray;
    [cell.segmentControl addTarget:self action:@selector(segChanged) forControlEvents:UIControlEventValueChanged];
    //    [cell configWithSongs:self.songs];
    //    cell.likeBlock = ^(NSInteger index) {
    //      SongModel *song = self.songs[index];
    //      song.isLiked = !song.isLiked;
    //      [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    //    };
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

