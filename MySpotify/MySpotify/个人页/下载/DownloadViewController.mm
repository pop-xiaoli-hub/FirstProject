//
//  DownloadViewController.m
//  MySpotify
//
//  Created by xiaoli pop on 2026/2/2.
//

#import "DownloadViewController.h"
#import "DBManager.h"
#import "LocalDownloadSongs.h"
#import "DownloadTableViewCell.h"
#import "DownloadTableHeaderView.h"
@interface DownloadViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong)UIImageView* backView;
@property (nonatomic, strong)UIVisualEffectView* blurView;
@property (nonatomic, strong)UIView* darkMaskView;
@property (nonatomic, strong)NSMutableArray* downloadedSongs;
@property (nonatomic, strong)UITableView* tableView;
@property (nonatomic, strong)DownloadTableHeaderView* headerView;
@end

@implementation DownloadViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self setBackgroudView];
  [self fetchDataFromDatabase];
    // Do any additional setup after loading the view.
}

- (void)fetchDataFromDatabase {
  DBManager* manager = [DBManager shared];
  NSArray* array = [manager queryOfDownloadSongs];
  self.downloadedSongs = [NSMutableArray arrayWithArray:array];
  for (LocalDownloadSongs* song in array) {
    NSLog(@"name:%@", song.songName);
  }
  [self createTableView];
  self.headerView = [[DownloadTableHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 140)];
  [self.headerView.buttonOfOpenSettings addTarget:self action:@selector(openSettings:) forControlEvents:UIControlEventTouchUpInside];
  self.tableView.tableHeaderView = self.headerView;
}

- (void)openSettings:(UIButton* )button {
  NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
  if ([[UIApplication sharedApplication] canOpenURL:url]) {
      [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
  }
}

- (void)createTableView {
  self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
  self.tableView.backgroundColor = [UIColor clearColor];
  self.tableView.dataSource = self;
  self.tableView.delegate = self;
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  [self.tableView registerClass:[DownloadTableViewCell class] forCellReuseIdentifier:@"cellOfSongs"];
  [self.view addSubview:self.tableView];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  DownloadTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cellOfSongs" forIndexPath:indexPath];
  [cell configWithSong:[self.downloadedSongs objectAtIndex:indexPath.row]];
  cell.backgroundColor = [UIColor clearColor];
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.downloadedSongs.count;
}

- (void)setBackgroudView {
  self.backView = [[UIImageView alloc] initWithFrame:self.view.bounds];
  self.backView.contentMode = UIViewContentModeScaleAspectFill;
  self.backView.clipsToBounds = YES;
  self.backView.image = [UIImage imageNamed:@"egg.jpg"];
  [self.view addSubview:self.backView];

  self.blurView = [[UIVisualEffectView alloc]
                   initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
  self.blurView.frame = self.view.bounds;
  [self.view addSubview:self.blurView];

  self.darkMaskView = [[UIView alloc] initWithFrame:self.view.bounds];
  self.darkMaskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.35];
  [self.view addSubview:self.darkMaskView];
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
