//
//  MinePageTableViewCell.m
//  MySpotify
//

#import "MinePageTableViewCell.h"
#import "SongModel.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/SDWebImage.h>
#import "ScrollTableViewCell.h"
#import "SongDBModel.h"
#import "MinePlaylistCollectionCell.h"

static NSString *const kPlaylistCellId = @"MinePlaylistCollectionCell";
static const CGFloat kPlaylistItemSize = 110;
static const CGFloat kPlaylistLineSpacing = 14;
static const CGFloat kPlaylistInteritemSpacing = 14;

static const CGFloat kDownloadButtonCornerRadius = 14;

@interface MinePageTableViewCell () <UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UILabel *playlistTitleLabel;
@property (nonatomic, strong) UIButton *downloadButton;
@property (nonatomic, strong) UIVisualEffectView *downloadButtonGlassView;
@property (nonatomic, strong) UIView *downloadHighlightOverlay;
@property (nonatomic, strong) UILabel *recentTitleLabel;
@property (nonatomic, copy) NSArray<NSDictionary<NSString *, NSString *> *> *playlistData;
@property (nonatomic, assign) NSInteger selectedPlaylistIndex;
@end

@implementation MinePageTableViewCell

static UIColor *spotifyGreen(void) {
  return [UIColor colorWithRed:29/255.0 green:185/255.0 blue:84/255.0 alpha:1];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    self.backgroundColor = UIColor.clearColor;
    self.contentView.backgroundColor = UIColor.clearColor;
    _playlistData = @[
      @{ @"title": @"爵士化专播", @"subtitle": @"36-11", @"url": @"https://picsum.photos/500/500?random=1" },
      @{ @"title": @"冷冷", @"subtitle": @"34-32", @"url": @"https://picsum.photos/600/600?random=2" },
      @{ @"title": @"流行", @"subtitle": @"36-39", @"url": @"https://picsum.photos/800/800?random=3" },
      @{ @"title": @"深清摇滚", @"subtitle": @"34-31", @"url": @"https://picsum.photos/1000/1000?random=4" }
    ];
    _selectedPlaylistIndex = 0;
    [self createPlaylistSection];
    [self createDownloadButton];
    [self createRecentSection];
  }
  return self;
}

- (void)createPlaylistSection {
  _playlistTitleLabel = [[UILabel alloc] init];
  _playlistTitleLabel.text = @"我的收藏歌单";
  _playlistTitleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
  _playlistTitleLabel.textColor = [UIColor whiteColor];
  [self.contentView addSubview:_playlistTitleLabel];

  UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
  layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
  layout.minimumLineSpacing = kPlaylistLineSpacing;
  layout.minimumInteritemSpacing = kPlaylistInteritemSpacing;
  layout.itemSize = CGSizeMake(kPlaylistItemSize, kPlaylistItemSize + 38);
  layout.sectionInset = UIEdgeInsetsZero;

  _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
  _collectionView.backgroundColor = [UIColor clearColor];
  _collectionView.showsHorizontalScrollIndicator = NO;
  _collectionView.delegate = self;
  _collectionView.allowsMultipleSelection = NO;
  _collectionView.dataSource = self;
  [_collectionView registerClass:[MinePlaylistCollectionCell class] forCellWithReuseIdentifier:kPlaylistCellId];
  [self.contentView addSubview:_collectionView];

  [_playlistTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.contentView).offset(20);
    make.top.equalTo(self.contentView).offset(12);
    make.height.mas_equalTo(24);
  }];
  [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.contentView).offset(20);
    make.right.equalTo(self.contentView).offset(-20);
    make.top.equalTo(_playlistTitleLabel.mas_bottom).offset(12);
    make.height.mas_equalTo(kPlaylistItemSize + 38);
  }];
}

- (void)createDownloadButton {
  UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
  _downloadButtonGlassView = [[UIVisualEffectView alloc] initWithEffect:effect];
  _downloadButtonGlassView.layer.cornerRadius = kDownloadButtonCornerRadius;
  _downloadButtonGlassView.layer.masksToBounds = YES;
  _downloadButtonGlassView.layer.borderWidth = 1;
  _downloadButtonGlassView.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.12].CGColor;
  _downloadButtonGlassView.alpha = 0.82;
  [self.contentView addSubview:_downloadButtonGlassView];

  _downloadHighlightOverlay = [[UIView alloc] init];
  _downloadHighlightOverlay.userInteractionEnabled = NO;
  _downloadHighlightOverlay.layer.cornerRadius = kDownloadButtonCornerRadius;
  _downloadHighlightOverlay.layer.masksToBounds = YES;
  CAGradientLayer *highlightGradient = [CAGradientLayer layer];
  highlightGradient.colors = @[
    (id)[UIColor colorWithWhite:1 alpha:0.22].CGColor,
    (id)[UIColor colorWithWhite:1 alpha:0.08].CGColor,
    (id)[UIColor colorWithWhite:1 alpha:0.02].CGColor
  ];
  highlightGradient.locations = @[@0, @0.5, @1];
  highlightGradient.startPoint = CGPointMake(0.5, 0);
  highlightGradient.endPoint = CGPointMake(0.5, 1);
  highlightGradient.frame = CGRectMake(0, 0, 320, 48);
  highlightGradient.cornerRadius = kDownloadButtonCornerRadius;
  [_downloadHighlightOverlay.layer addSublayer:highlightGradient];
  [self.contentView addSubview:_downloadHighlightOverlay];

  _downloadButton = [UIButton buttonWithType:UIButtonTypeSystem];
  [_downloadButton setTitle:@"我的下载" forState:UIControlStateNormal];
  _downloadButton.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
  [_downloadButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  _downloadButton.backgroundColor = [UIColor clearColor];
  [_downloadButton addTarget:self action:@selector(downloadButtonTapped) forControlEvents:UIControlEventTouchUpInside];
  [self.contentView addSubview:_downloadButton];

  [_downloadButtonGlassView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.contentView).offset(20);
    make.right.equalTo(self.contentView).offset(-20);
    make.top.equalTo(_collectionView.mas_bottom).offset(14);
    make.height.mas_equalTo(48);
  }];
  [_downloadHighlightOverlay mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(_downloadButtonGlassView);
  }];
  [_downloadButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(_downloadButtonGlassView);
  }];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  if (_downloadHighlightOverlay.layer.sublayers.count > 0) {
    CAGradientLayer *gradient = (CAGradientLayer *)_downloadHighlightOverlay.layer.sublayers.firstObject;
    if ([gradient isKindOfClass:[CAGradientLayer class]]) {
      gradient.frame = _downloadHighlightOverlay.bounds;
      gradient.cornerRadius = kDownloadButtonCornerRadius;
    }
  }
}

- (void)downloadButtonTapped {
  if (self.downloadButtonBlock) {
    self.downloadButtonBlock();
  }
  if (self.buttonClickBlock) {
    self.buttonClickBlock(_downloadButton);
  }
}

- (void)createRecentSection {
  _recentTitleLabel = [[UILabel alloc] init];
  _recentTitleLabel.text = @"最近播放";
  _recentTitleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
  _recentTitleLabel.textColor = [UIColor whiteColor];
  [self.contentView addSubview:_recentTitleLabel];

  _tableViewOfSongs = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
  _tableViewOfSongs.backgroundColor = [UIColor clearColor];
  _tableViewOfSongs.scrollEnabled = NO;
  _tableViewOfSongs.separatorStyle = UITableViewCellSeparatorStyleNone;
  _tableViewOfSongs.delegate = self;
  _tableViewOfSongs.dataSource = self;
  [_tableViewOfSongs registerClass:[ScrollTableViewCell class] forCellReuseIdentifier:@"cellOfSongs"];
  [self.contentView addSubview:_tableViewOfSongs];

  [_recentTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.contentView).offset(20);
    make.top.equalTo(_downloadButtonGlassView.mas_bottom).offset(20);
    make.height.mas_equalTo(24);
  }];
  [_tableViewOfSongs mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.right.equalTo(self.contentView);
    make.top.equalTo(_recentTitleLabel.mas_bottom).offset(12);
    make.height.mas_equalTo(0).priorityHigh();
  }];
}

- (void)setLocalSongArray:(NSMutableArray *)localSongArray {
  _localSongArray = localSongArray ? [NSMutableArray arrayWithArray:localSongArray] : [NSMutableArray array];
  [_tableViewOfSongs reloadData];
  CGFloat listH = (CGFloat)(_localSongArray.count * 72);
  [_tableViewOfSongs mas_updateConstraints:^(MASConstraintMaker *make) {
    make.height.mas_equalTo(listH);
  }];
}

#pragma mark - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return _playlistData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  MinePlaylistCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPlaylistCellId forIndexPath:indexPath];
  NSDictionary *item = _playlistData[indexPath.item];
  BOOL selected = (indexPath.item == _selectedPlaylistIndex);//默认选择第一个，如果发现点击的item不是当前Index，select为false，即未选中
  [cell configWithTitle:item[@"title"] subtitle:item[@"subtitle"] imageURL:item[@"url"] selected:selected];
  return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  BOOL changed = (indexPath.item != _selectedPlaylistIndex);//判断是否点击的是同一个item
  if (changed) {//如果点击的是同一个item执行
    NSIndexPath *previous = [NSIndexPath indexPathForItem:_selectedPlaylistIndex inSection:0];
    _selectedPlaylistIndex = indexPath.item;
    [collectionView performBatchUpdates:^{
      [collectionView reloadItemsAtIndexPaths:@[previous, indexPath]];
    } completion:^(BOOL finished) {
      MinePlaylistCollectionCell *cell = (MinePlaylistCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
      if ([cell isKindOfClass:[MinePlaylistCollectionCell class]]) {
        [cell playSelectAnimation];
      }
    }];
  } else {
    MinePlaylistCollectionCell *cell = (MinePlaylistCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:[MinePlaylistCollectionCell class]]) {
      [cell playSelectAnimation];
    }
  }
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
  MinePlaylistCollectionCell *cell = (MinePlaylistCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
  if ([cell isKindOfClass:[MinePlaylistCollectionCell class]]) {
    [cell setHighlighted:YES];
  }
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
  MinePlaylistCollectionCell *cell = (MinePlaylistCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
  if ([cell isKindOfClass:[MinePlaylistCollectionCell class]]) {
    [cell setHighlighted:NO];
  }
}




#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return (NSInteger)self.localSongArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 72;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  ScrollTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellOfSongs" forIndexPath:indexPath];
  cell.cellType = CustomCollectionViewCellTypeSong;
  cell.backgroundColor = [UIColor clearColor];
  cell.indexLabel.text = [NSString stringWithFormat:@"%ld", (long)(indexPath.row + 1)];
  if (indexPath.row < (NSInteger)self.localSongArray.count) {
    SongDBModel *model = self.localSongArray[indexPath.row];
    [cell configWithSong:model];
    SDImageResizingTransformer *transformer = [SDImageResizingTransformer transformerWithSize:CGSizeMake(200, 200) scaleMode:SDImageScaleModeAspectFill];
    [cell.songImageView sd_setImageWithURL:[NSURL URLWithString:model.picUrl] placeholderImage:nil options:SDWebImageScaleDownLargeImages context:@{
      SDWebImageContextImageTransformer: transformer,
      SDWebImageContextImageThumbnailPixelSize: @(CGSizeMake(200, 200)),
      SDWebImageContextImageForceDecodePolicy: @(SDImageForceDecodePolicyNever)
    }];
  }
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  return cell;
}

- (void)configWithSongs:(NSArray<SongModel *> *)songs {
}

@end
