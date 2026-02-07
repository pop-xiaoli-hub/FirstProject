//
//  SongListViewController.m
//  MySpotify
//
//  Created by xiaoli pop on 2026/1/20.
//

#import "SongListViewController.h"
#import "SongModel.h"
#import "SongListTableViewCell.h"
#import "SongListHeaderView.h"
#import "SpotifyService.h"
#import "PlaylistModel.h"
#import "PlaylistDetailResponseModel.h"
#import <SDWebImage/SDWebImage.h>
#import "TracksIDModel.h"
#import "SongListFooterView.h"
@interface SongListViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, assign)NSInteger id;
@property (nonatomic, assign)SongListType type;
@property (nonatomic, strong)NSMutableArray<SongModel* >* songs;
@property (nonatomic, strong)PlaylistModel* playlistModel;
@property (nonatomic, strong)UIImageView* backView;
@property (nonatomic, strong)UIVisualEffectView* blurView;
@property (nonatomic, strong)UIView* darkMaskView;
@property (nonatomic, strong) SongListFooterView *footerView;
@property (nonatomic, strong) NSArray<TracksIDModel *> *allTrackIds;
@property (nonatomic, assign) NSInteger currentIndex;   // 当前加载到哪
@property (nonatomic, assign) NSInteger pageSize;       // 每批加载多少
@property (nonatomic, assign) BOOL isLoading;


@end

@implementation SongListViewController

- (instancetype)initWithId:(NSInteger)id type:(SongListType)type name:(NSString *)name {
  if (self = [super init]) {
    _id = id;
    _type = type;
    _pageSize = 20;
    self.title = [name copy];
    self.songs = [NSMutableArray array];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
  [appearance configureWithTransparentBackground];
  appearance.titleTextAttributes = @{
    NSForegroundColorAttributeName : UIColor.whiteColor,
    NSFontAttributeName : [UIFont boldSystemFontOfSize:17]
  };
  appearance.largeTitleTextAttributes = @{
    NSForegroundColorAttributeName : UIColor.whiteColor
  };
  self.navigationItem.standardAppearance = appearance;
  self.navigationItem.scrollEdgeAppearance = appearance;
  self.view.backgroundColor = [UIColor blackColor];
  [self setBackgroudView];
  [self setupTableView];
  NSLog(@"navigationController = %@", self.navigationController);
  [self requestData];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self.navigationController setNavigationBarHidden:NO animated:YES];
}


- (void)setBackgroudView {
  self.backView = [[UIImageView alloc] initWithFrame:self.view.bounds];
  self.backView.contentMode = UIViewContentModeScaleAspectFill;
  self.backView.clipsToBounds = YES;
  [self.view addSubview:self.backView];

  self.blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
  self.blurView.frame = self.view.bounds;
  [self.view addSubview:self.blurView];

  self.darkMaskView = [[UIView alloc] initWithFrame:self.view.bounds];
  self.darkMaskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.35];
  [self.view addSubview:self.darkMaskView];
}


- (void)setupTableView {
  self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.rowHeight = 60;
  self.tableView.backgroundColor = UIColor.clearColor;
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

  [self.tableView registerClass:[SongListTableViewCell class] forCellReuseIdentifier:@"cellOfSongs"];

  [self.view addSubview:self.tableView];
}

- (void)setUpTableHeaderView {
  if (!self.headerView) {
    self.headerView = [[SongListHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 450)];
    //self.headerView.delegate = self;
  }
  //
  self.tableView.tableHeaderView = self.headerView;
}

- (void)requestData {
  __weak typeof(self) weakSelf = self;
  SpotifyService* service = [SpotifyService sharedInstance];
  NSString* idOfList = [NSString stringWithFormat:@"%ld", self.id];
  [service fetchPlaylistDetailWithId:idOfList completion:^(id  _Nonnull responseObject, NSError * _Nonnull error) {
    PlaylistDetailResponseModel* responseModel = [PlaylistDetailResponseModel yy_modelWithJSON:responseObject];
    PlaylistModel *playlist = responseModel.playlist;
    NSArray<SongModel *> *songs = playlist.tracks;
    NSLog(@"歌单名：%@", playlist.name);
    NSLog(@"歌曲数量：%lu", (unsigned long)songs.count);
    NSLog(@"%@", responseObject);
    [weakSelf handleResponse:playlist];
  }];
}



- (void)handleResponse:(PlaylistModel *)playlistModel{
  NSArray<SongModel *> *songs = playlistModel.tracks;
  self.playlistModel = playlistModel;
  SDImageResizingTransformer *transformer = [SDImageResizingTransformer transformerWithSize:CGSizeMake(200, 200) scaleMode:SDImageScaleModeAspectFill];
  [self.backView sd_setImageWithURL:[NSURL URLWithString:playlistModel.coverImgUrl] placeholderImage:nil options:SDWebImageScaleDownLargeImages context:@{ SDWebImageContextImageTransformer: transformer, SDWebImageContextImageThumbnailPixelSize: @(CGSizeMake(200, 200)), SDWebImageContextImageForceDecodePolicy: @(SDImageForceDecodePolicyNever)
  }];
  [self.songs removeAllObjects];
  [self.songs addObjectsFromArray:songs];
  NSArray* tracksId = playlistModel.trackIds;
  for (int i = 0; i < tracksId.count; i++) {
    TracksIDModel* trackIDModel = tracksId[i];
    NSLog(@"%lld", trackIDModel.id);
  }
  self.allTrackIds = playlistModel.trackIds;
  self.currentIndex = playlistModel.tracks.count;
  [self setUpTableHeaderView];
  [self setupTableFooter];
  [self.headerView configWithPlayList:playlistModel];
  [self.tableView reloadData];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  if (self.isLoading) {
    return;
  }
  CGFloat offsetY = scrollView.contentOffset.y;
  CGFloat contentHeight = scrollView.contentSize.height;
  CGFloat frameHeight = scrollView.frame.size.height;
  if (offsetY > contentHeight - frameHeight - 50) {
    [self loadMoreSongs];
  }
}

- (NSArray<TracksIDModel *> *)nextTrackIdSlice {
  if (self.currentIndex >= self.allTrackIds.count) {
    return nil;
  }
  NSInteger length = MIN(self.pageSize, self.allTrackIds.count - self.currentIndex);
  NSArray *slice = [self.allTrackIds subarrayWithRange: NSMakeRange(self.currentIndex, length)];
  return slice;
}

- (NSString *)idsStringFromSlice:(NSArray<TracksIDModel *> *)slice {

  NSMutableArray *ids = [NSMutableArray array];
  for (SongModel *model in slice) {
    [ids addObject:@(model.id).stringValue];
  }
  return [ids componentsJoinedByString:@","];
}



- (void)loadMoreSongs {

  if (self.isLoading) {
    return;
  }
  self.isLoading = YES;

  NSArray *slice = [self nextTrackIdSlice];
  if (!slice) {
    [self.footerView setState:LoadMoreStateNoMoreData];
    self.isLoading = NO;
    return;
  }

  NSString *ids = [self idsStringFromSlice:slice];

  __weak typeof(self) weakSelf = self;
  SpotifyService* service = [SpotifyService sharedInstance];
  [service fetchSongsWithIds:ids completion:^(NSArray<SongModel *> * _Nonnull songs, NSError * _Nonnull error) {
    [weakSelf.songs addObjectsFromArray:songs];
    weakSelf.currentIndex += slice.count;
    [weakSelf.tableView reloadData];
    [weakSelf.footerView setState:LoadMoreStateIdle];
    weakSelf.isLoading = NO;
  }];
}



- (void)setupTableFooter {
  self.footerView = [[SongListFooterView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 50)];
  self.tableView.tableFooterView = self.footerView;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.songs.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  SongListTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cellOfSongs" forIndexPath:indexPath];
  [cell configWithSong:[self.songs objectAtIndex:indexPath.row]];
  cell.backgroundColor = [UIColor clearColor];
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  return cell;
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
