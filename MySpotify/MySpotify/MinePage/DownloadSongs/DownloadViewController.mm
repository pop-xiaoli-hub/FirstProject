//
//  DownloadViewController.m
//  MySpotify
//
//  Created by xiaoli pop on 2026/2/2.
//

#import "DownloadViewController.h"
#import "DBManager.h"
#import "LocalDownloadSongs.h"
#import "LocalDownloadSongs+WCTTableCoding.h"
#import "DownloadTableViewCell.h"
#import "DownloadTableHeaderView.h"
#import "PlaylistManager.h"
#import "SongPlayingModel.h"
#import "MusicPlayerManager.h"
#import "MusicPlayerController.h"
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
  [self.headerView.buttonOfPlayAllSongs addTarget:self action:@selector(playAllSongs:) forControlEvents:UIControlEventTouchUpInside];
  [self.headerView.buttonOfSelectSongs addTarget:self action:@selector(deleteSongs:) forControlEvents:UIControlEventTouchUpInside];
    // Do any additional setup after loading the view.
}

- (void)deleteSongs:(UIButton*) button {
  button.selected = !button.selected;
  if (button.selected) {
    [self.tableView setEditing:YES animated:YES];
  } else {
    [self.tableView setEditing:NO animated:YES];
  }
}

- (void)deleteSelectedRows {
    // 获取选中的 indexPath
    NSArray<NSIndexPath *> *selectedRows = [self.tableView indexPathsForSelectedRows];
    if (selectedRows.count == 0) {
        NSLog(@"没有选中任何行");
        return;
    }
    // 按照逆序删除，避免索引混乱
  NSArray *sortedRows = [selectedRows sortedArrayUsingComparator:^NSComparisonResult(NSIndexPath *obj1, NSIndexPath *obj2) {
      if (obj2.row > obj1.row) return NSOrderedDescending;
      if (obj2.row < obj1.row) return NSOrderedAscending;
      return NSOrderedSame;
  }];
    // 从数据源删除对应的数据
    for (NSIndexPath *indexPath in sortedRows) {
        [self.downloadedSongs removeObjectAtIndex:indexPath.row];
    }
    // 从表格删除对应行
    [self.tableView deleteRowsAtIndexPaths:sortedRows withRowAnimation:UITableViewRowAnimationAutomatic];
}




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if(tableView.isEditing) {
    return;
  }
  PlaylistManager* listManager = [PlaylistManager shared];
  listManager.currentIndex = indexPath.row;
  LocalDownloadSongs* localSong = [self.downloadedSongs objectAtIndex:indexPath.row];
  SongPlayingModel* playingSong = [[SongPlayingModel alloc] initWithSongName:localSong.songName andArtistName:localSong.artistName andSongId:localSong.songId andPicUrl:localSong.picUrl andMusicSource:localSong.localPath andIsDownloaded:YES];
  for (int i = 0; i < listManager.playlist.count; i++) {
    SongPlayingModel* model = [listManager.playlist objectAtIndex:i];
    if (model.songId == playingSong.songId) {
      [listManager.playlist removeObject:model];
    }
    NSLog(@"name: %@", model.name);
  }
  [listManager.playlist insertObject:playingSong atIndex:0];
  [[MusicPlayerManager sharedManager] playWithSong:playingSong];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"playDownloadSong" object:nil userInfo:@{
      @"index" : @(0),
      @"type" : @"download"
  }];
  [self jumpToPlayerViewController];
}

- (void)jumpToPlayerViewController {
  MusicPlayerController* vc = [[MusicPlayerController alloc] init];
  PlaylistManager* manager = [PlaylistManager shared];
  vc.musicPlayList = manager.playlist;
  vc.currentIndex = manager.currentIndex;
  vc.isplaying = YES;
  [self presentViewController:vc animated:YES completion:nil];
}

- (void)playAllSongs:(UIButton* )button {
  MusicPlayerManager* playManager = [MusicPlayerManager sharedManager];
  [playManager stop];
  PlaylistManager* listManager = [PlaylistManager shared];
  [listManager.playlist removeAllObjects];
  for (int i = 0; i < self.downloadedSongs.count; i++) {
    LocalDownloadSongs* localSong = self.downloadedSongs[i];
    SongPlayingModel* playingModel = [[SongPlayingModel alloc] initWithSongName:localSong.songName andArtistName:localSong.artistName andSongId:localSong.songId andPicUrl:localSong.picUrl andMusicSource:localSong.localPath andIsDownloaded:YES];
    [listManager.playlist addObject:playingModel];
  }
  listManager.currentIndex = 0;
  [playManager playWithSong:[listManager.playlist objectAtIndex:listManager.currentIndex]];
  NSDictionary* userInfo = @{
    @"isPressed" : @(YES)
  };
  [[NSNotificationCenter defaultCenter] postNotificationName:@"playLocalSong" object:nil userInfo:userInfo];
}

- (void)fetchDataFromDatabase {
  DBManager* manager = [DBManager shared];
  NSArray* array = [manager queryOfDownloadSongs];
  self.downloadedSongs = [NSMutableArray arrayWithArray:array];
  for (LocalDownloadSongs* song in array) {
    NSLog(@"name:%@", song.songName);
    NSLog(@"歌曲路径：%@", song.localPath);
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
  self.tableView.allowsMultipleSelectionDuringEditing = YES;
  [self.tableView registerClass:[DownloadTableViewCell class] forCellReuseIdentifier:@"cellOfSongs"];
  [self.view addSubview:self.tableView];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  DownloadTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cellOfSongs" forIndexPath:indexPath];
  [cell configWithSong:[self.downloadedSongs objectAtIndex:indexPath.row]];
  cell.backgroundColor = [UIColor clearColor];
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  [cell.moreButton addTarget:self action:@selector(pressMore:) forControlEvents:UIControlEventTouchUpInside];
  return cell;
}

- (void)pressMore:(UIButton* )button {
  
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
