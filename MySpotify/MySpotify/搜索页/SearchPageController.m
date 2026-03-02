//
//  SearchPageController.m
//  MySpotify
//
//  Created by xiaoli pop on 2025/11/17.
//
#import "SearchPageController.h"
#import "SearchPageView.h"
#import "MyCollectionViewLayout.h"
#import "SpotifyService.h"
#import "SDWebImage.h"
#import "SongModel.h"
#import "RecommendedSongsItemModel.h"
#import "AlbumModel.h"
#import "MyCollectionViewCell.h"
#import "CommentModel.h"
#import "CommentUserModel.h"
#import "commentViewController.h"
#import "ArtistModel.h"
#import "SongListTableViewCell.h"
#import "MusicPlayerController.h"
#import "PLaylistManager.h"
#import "SongPlayingModel.h"
@interface SearchPageController ()<UICollectionViewDelegate, UICollectionViewDataSource, MyCollectionViewLayoutDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic,strong) SearchPageView *myView;
@property (nonatomic,strong) SpotifyService *service;
@property (nonatomic,strong) NSMutableArray *mutableArrayOfSongs;
@property (nonatomic, strong) NSMutableArray* searchResultSongs;
@property (nonatomic,assign) NSInteger page;
@property (nonatomic,assign) BOOL isLoading;
@property (nonatomic,assign) BOOL hasMore;
@property (nonatomic, assign)NSInteger index;
@property (nonatomic, strong) NSTimer *searchTimer;
@end

@implementation SearchPageController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.index = 30;
  self.service = [SpotifyService sharedInstance];
  self.mutableArrayOfSongs = [NSMutableArray array];
  self.searchResultSongs = [NSMutableArray array];
  self.page = 1;
  self.hasMore = YES;
  self.isLoading = NO;
  [self setUpUI];
  [self fetchCurrentPageData];
  self.myView.resultTableview.delegate = self;
  self.myView.resultTableview.dataSource = self;
  [self.myView.resultTableview registerClass:[SongListTableViewCell class] forCellReuseIdentifier:@"cellOfSongs"];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
  [self.myView.searchBar.searchTextField addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.searchResultSongs.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  SongModel* song = [self.searchResultSongs objectAtIndex:indexPath.row];
  ArtistModel* artist = [song.artists objectAtIndex:0];
  AlbumModel* album = song.album;
  SongPlayingModel* playingModel = [[SongPlayingModel alloc] initWithSongName:song.name andArtistName:artist.name andSongId:song.id andPicUrl:artist.img1v1Url andMusicSource:@"null" andIsDownloaded:NO];
  NSLog(@"封面：%@", album.picUrl);
  SpotifyService* service = [SpotifyService sharedInstance];
  PlaylistManager* listManager = [PlaylistManager shared];
  listManager.currentIndex = 0;
  [listManager.playlist insertObject:playingModel atIndex:0];
  __weak typeof (self) weakSelf = self;
  [service fetchSongResources:playingModel completion:^(BOOL temp) {
      if (temp) {
        NSLog(@"%@", playingModel.audioResources);
        [weakSelf jumpToPlayerViewController];
      }
  }];
  NSLog(@"dianji");
}

- (void)jumpToPlayerViewController {
  MusicPlayerController* vc = [[MusicPlayerController alloc] init];
  PlaylistManager* manager = [PlaylistManager shared];
  vc.musicPlayList = manager.playlist;
  vc.currentIndex = manager.currentIndex;
  vc.isplaying = YES;
  [self presentViewController:vc animated:YES completion:nil];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  SongListTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cellOfSongs" forIndexPath:indexPath];
  [cell configWithSearchResultSong:[self.searchResultSongs objectAtIndex:indexPath.row]];
  cell.backgroundColor = [UIColor clearColor];
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  return cell;
}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
//  // 如果 searchBar 没有文字，无论点击哪里都收起键盘
//  if (self.myView.searchBar.text.length == 0) {
//    return YES;
//  }
//  // 有文字时，点击 cell 不收起，点击空白区域收起
//  CGPoint location = [touch locationInView:self.myView.resultTableview];
//  NSIndexPath *indexPath = [self.myView.resultTableview indexPathForRowAtPoint:location];
//
//  return (indexPath == nil);
//}



- (void)textDidChange:(UITextField *)textField {
  NSString *keyword = textField.text;
  [self debounceSearch:keyword];
}

- (void)debounceSearch:(NSString *)keyword {
  [self.searchTimer invalidate];
  self.searchTimer = nil;
  // 延迟 0.4 秒执行搜索
  self.searchTimer = [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(performSearch:) userInfo:keyword repeats:NO];
}

- (void)performSearch:(NSTimer *)timer {
  NSString *keyword = (NSString *)timer.userInfo;
  if (keyword.length == 0) return;
  SpotifyService* service = [SpotifyService sharedInstance];
  //service requestSearchAPI:keyword];
  __weak typeof(self) weakSelf = self;
  [service searchSongs:keyword withCompletion:^(NSArray * _Nonnull songs, NSError * _Nonnull error) {
    [weakSelf responseSearchResultWithSongs:songs];
  }];
}

- (void)responseSearchResultWithSongs:(NSArray* )songs {
  self.searchResultSongs = [NSMutableArray arrayWithArray:songs];
  [self.myView.resultTableview reloadData];
  for (SongModel* song in songs) {
    ArtistModel* artist = [song.artists objectAtIndex:0];
    AlbumModel* album = song.album;
    NSLog(@"%@- %@- %@", song.name,artist.name, artist.img1v1Url);
  }
}

- (void)keyboardWillShow:(NSNotification *)notification {
  //    NSDictionary *userInfo = notification.userInfo;
  //    CGRect keyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
  //    CGFloat keyboardHeight = keyboardFrame.size.height;
  //    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
  //    UIViewAnimationOptions options = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue] << 16;
  //    NSLog(@"键盘弹出，高度：%f", keyboardHeight);
  //    [UIView animateWithDuration:duration delay:0 options:options animations:^{
  //      [self.myView showResultTable];
  //    } completion:nil];
  [self.myView showResultTable];
}



- (void)keyboardWillHide:(NSNotification *)notification {
  if (!self.myView.searchBar.text.length) {
    [self.myView hideResultTable];
    [self.searchResultSongs removeAllObjects];
    [self.myView.resultTableview reloadData];
    self.myView.searchBar.text = nil;
  }
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  CommentViewController* vc = [[CommentViewController alloc] init];
  //  vc.modalPresentationStyle = UIModalPresentationFullScreen;
  RecommendedSongsItemModel *item = self.mutableArrayOfSongs[indexPath.row];
  SongModel *songModel = item.song;
  vc.songModel = songModel;
  [self presentViewController:vc animated:YES completion:nil];
}


- (void)fetchCurrentPageData {
  if (self.isLoading || !self.hasMore) return;
  self.isLoading = YES;
  __weak typeof(self) weakSelf = self;
  [self.service fetchSomeSongsWithIndex:self.index withCompletion:^(NSMutableArray * _Nonnull arrayOfSongs, NSError * _Nonnull error) {
    if (weakSelf.page == 1) {
      [weakSelf.mutableArrayOfSongs removeAllObjects];
    }
    [weakSelf.mutableArrayOfSongs removeAllObjects];
    [weakSelf.mutableArrayOfSongs addObjectsFromArray:arrayOfSongs];

    if (arrayOfSongs.count == 0) {
      weakSelf.hasMore = NO;
    }

    weakSelf.isLoading = NO;
    self.index += 15;
    //    for (RecommendedSongsItemModel* item in  arrayOfSongs) {
    //      SongModel* songModel = item.song;
    //      NSInteger index = [self.mutableArrayOfSongs indexOfObject:item];
    //      NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    //      [self.service fetchCommentsOfSongs:songModel withCompletion:^(NSError * _Nonnull error) {
    //        if (error) {
    //          NSLog(@"%@" ,error);
    //        }
    //        dispatch_async(dispatch_get_main_queue(), ^{
    //            [self.myView.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    //        });
    //      }];
    //    }
    [self.myView.collectionView reloadData];
  }];
}

- (void)loadMoreData {
  if (self.isLoading || !self.hasMore) {
    return;
  }
  self.page++;
  [self fetchCurrentPageData];
}



- (void)setUpUI {
  self.view.backgroundColor = [UIColor whiteColor];
  self.myView = [[SearchPageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
  [self.view addSubview:self.myView];
  self.myView.collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
  MyCollectionViewLayout *layout = (MyCollectionViewLayout *)self.myView.collectionView.collectionViewLayout;
  layout.delegate = self;
  self.myView.collectionView.delegate = self;
  self.myView.collectionView.dataSource = self;
  [self.myView.collectionView registerClass:[MyCollectionViewCell class] forCellWithReuseIdentifier:@"cell01"];
  UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissMyKeyboard)];
  tap.cancelsTouchesInView = NO;
  tap.delegate = self;
  [self.myView.resultTableview addGestureRecognizer:tap];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  CGFloat offsetY = scrollView.contentOffset.y;
  CGFloat contentHeight = scrollView.contentSize.height;
  CGFloat height = scrollView.bounds.size.height;

  if (offsetY > contentHeight - height - 150) {
    NSLog(@"刷新新一页的数据");
    [self loadMoreData];
  }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return self.mutableArrayOfSongs.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  MyCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell01"  forIndexPath:indexPath];
  cell.layer.masksToBounds = YES;
  cell.layer.cornerRadius = 10;
  cell.backgroundColor = [UIColor colorWithRed:41/225.0f green:42/225.0f blue:60/225.0f alpha:0.8];
  RecommendedSongsItemModel *item = self.mutableArrayOfSongs[indexPath.row];
  SongModel *songModel = item.song;
  AlbumModel *albumModel = songModel.album;
  CommentUserModel* user = songModel.comments.user;
  SDImageResizingTransformer *transformer =
  [SDImageResizingTransformer transformerWithSize:CGSizeMake(200, 200)  scaleMode:SDImageScaleModeAspectFill];
  NSLog(@"歌曲评论属性添加成功:%@, 点赞数：%ld", songModel.comments.content, songModel.comments.likedCount);
  [cell configureWithCommentModel:songModel.comments];
  [cell.headerView sd_setImageWithURL:[NSURL URLWithString:user.avatarUrl] placeholderImage:nil options:SDWebImageScaleDownLargeImages context:@{
    SDWebImageContextImageTransformer: transformer
  }];
  [cell.coverImageView sd_setImageWithURL:[NSURL URLWithString:albumModel.picUrl] placeholderImage:nil options:SDWebImageScaleDownLargeImages context:@{
    SDWebImageContextImageTransformer: transformer
  }];
  cell.buttonOfLiked.selected = songModel.isLiked;
  cell.buttonOfLiked.tag = indexPath.row;
  [cell.buttonOfLiked addTarget:self action:@selector(pressButtonOfLiked:) forControlEvents:UIControlEventTouchUpInside];

  //  [cell createButtton];
  return cell;
}


- (void)pressButtonOfLiked:(UIButton *)button {
  NSInteger index = button.tag;
  if (index < 0 || index >= self.mutableArrayOfSongs.count) {
    return;
  }
  RecommendedSongsItemModel *item = self.mutableArrayOfSongs[index];
  SongModel *songModel = item.song;
  songModel.isLiked = !songModel.isLiked;
  CommentModel* commentModel = songModel.comments;
  if (songModel.isLiked) {
    commentModel.likedCount += 1;
  } else {
    commentModel.likedCount -= 1;
  }
  NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:0];
  MyCollectionViewCell* cell = [self.myView.collectionView cellForItemAtIndexPath:indexPath];
  cell.labelOfLiked.text = [[NSString stringWithFormat:@"%ld", commentModel.likedCount] copy];
  button.selected = songModel.isLiked;
}



- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
  RecommendedSongsItemModel *item = self.mutableArrayOfSongs[indexPath.row];
  SongModel *songModel = item.song;
  if (songModel.comments || songModel.isFetchingComments) {
    return;
  }
  songModel.isFetchingComments = YES;
  __weak typeof(self) weakSelf = self;
  [self.service fetchCommentsOfSongs:songModel withCompletion:^(NSError *error) {
    songModel.isFetchingComments = NO;
    if (error) return;
    dispatch_async(dispatch_get_main_queue(), ^{
      // 只刷新当前 cell
      //            MyCollectionViewCell* cell = [weakSelf.myView.collectionView cellForItemAtIndexPath:indexPath];
      //            [cell createButtton];
      [weakSelf.myView.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    });
  }];
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout heightForItemAtIndexPath:(NSIndexPath *)indexPath itemWidth:(CGFloat)width {
  if (indexPath.row == 1) {
    return 200;
  } else {
    return 350;
  }
}

- (void)dismissMyKeyboard {
  [self.myView endEditing:YES];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
  [self.view endEditing:YES];
  [self.myView hideResultTable];
  [self.searchResultSongs removeAllObjects];
  [self.myView.resultTableview reloadData];
  self.myView.searchBar.text = nil;
}

@end
