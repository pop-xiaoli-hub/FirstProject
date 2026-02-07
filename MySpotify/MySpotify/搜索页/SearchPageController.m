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
@interface SearchPageController ()<UICollectionViewDelegate, UICollectionViewDataSource, MyCollectionViewLayoutDelegate>

@property (nonatomic,strong) SearchPageView *myView;
@property (nonatomic,strong) SpotifyService *service;
@property (nonatomic,strong) NSMutableArray *mutableArrayOfSongs;

@property (nonatomic,assign) NSInteger page;
@property (nonatomic,assign) BOOL isLoading;
@property (nonatomic,assign) BOOL hasMore;
@property (nonatomic, assign)NSInteger index;
@end

@implementation SearchPageController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.index = 30;
  self.service = [SpotifyService sharedInstance];
  self.mutableArrayOfSongs = [NSMutableArray array];

  self.page = 1;
  self.hasMore = YES;
  self.isLoading = NO;

  [self setUpUI];
  [self fetchCurrentPageData];
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
  [self.myView.collectionView addGestureRecognizer:tap];
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

@end
