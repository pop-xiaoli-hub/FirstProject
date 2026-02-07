//
//  MinePageTableViewCell.m
//  MySpotify
//
//  Created by xiaoli pop on 2026/1/15.
//

#import "MinePageTableViewCell.h"
#import "SongModel.h"
#import <Masonry/Masonry.h>
#import "AlbumModel.h"
#import <SDWebImage/SDWebImage.h>
#import "ArtistModel.h"
#import "ScrollTableViewCell.h"
#import "SongDBModel.h"
@interface MinePageTableViewCell ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation MinePageTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    self.backgroundColor = UIColor.clearColor;
    [self creatStackView];
    [self createSegmentControl];
    [self createScrollView];
  }
  return self;
}


- (void)createScrollView {
  self.scrollView = [[UIScrollView alloc] init];
  self.scrollView.frame = CGRectMake(0, 195, [[UIScreen mainScreen] bounds].size.width, 800);
  self.scrollView.contentSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width * 3, 800);
  self.scrollView.backgroundColor = [UIColor clearColor];
  self.scrollView.pagingEnabled = YES;
  self.scrollView.scrollEnabled = YES;
  self.scrollView.bounces = NO;
  [self createTableViews];
  [self.contentView addSubview:self.scrollView];
}

- (void)createTableViews {
  CGFloat width = [[UIScreen mainScreen] bounds].size.width;
  self.tableViewOfSongs = [[UITableView alloc] initWithFrame: CGRectMake(0, 0, width, 800)];
  self.tableViewOfSongs.backgroundColor = [UIColor clearColor];

  self.tableViewOfSongs.scrollEnabled = NO;
  self.tableViewOfSongs.delegate = self;
  self.tableViewOfSongs.dataSource = self;
  [self.scrollView addSubview:self.tableViewOfSongs];

  self.tableViewOfPodcasting = [[UITableView alloc] initWithFrame:CGRectMake(width, 0, width, 800)];
  self.tableViewOfPodcasting.backgroundColor = [UIColor clearColor];

  self.tableViewOfPodcasting.scrollEnabled = NO;
  self.tableViewOfPodcasting.delegate = self;
  self.tableViewOfPodcasting.dataSource = self;
  [self.scrollView addSubview:self.tableViewOfPodcasting];

  self.tableViewOfNotes =  [[UITableView alloc] initWithFrame:CGRectMake(width * 2, 0, width, 800)];
  self.tableViewOfNotes.backgroundColor = [UIColor clearColor];

  self.tableViewOfNotes.scrollEnabled = NO;
  [self.scrollView addSubview:self.tableViewOfNotes];
  self.tableViewOfNotes.delegate = self;
  self.tableViewOfNotes.dataSource = self;
  [self.tableViewOfNotes registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellOfNotes"];
  [self.tableViewOfSongs registerClass:[ScrollTableViewCell class] forCellReuseIdentifier:@"cellOfSongs"];
  [self.tableViewOfPodcasting registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellOfPodcasting"];
  self.tableViewOfSongs.tag = 101;
  self.tableViewOfPodcasting.tag = 102;
  self.tableViewOfNotes.tag = 103;
  [self.tableViewOfSongs reloadData];
  [self.tableViewOfPodcasting reloadData];
  [self.tableViewOfNotes reloadData];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.localSongArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (tableView == self.tableViewOfSongs) {
    return 80;
  } else {
    return 100;
  }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (tableView == self.tableViewOfSongs) {
    ScrollTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellOfSongs"  forIndexPath:indexPath];
    cell.cellType = CustomCollectionViewCellTypeSong;
    cell.backgroundColor = [UIColor clearColor];
    SongDBModel* model = [self.localSongArray objectAtIndex:indexPath.row];
    [cell configWithSong:model];
    SDImageResizingTransformer *transformer =
    [SDImageResizingTransformer transformerWithSize:CGSizeMake(200, 200) scaleMode:SDImageScaleModeAspectFill];
    /*
     创建一个图片转换器transformer,用于在图片加载后对UIImage做重新绘制/缩放的类，在图片被解码后将图片重新渲染成指定尺寸
     */
    [cell.songImageView sd_setImageWithURL:[NSURL URLWithString:model.picUrl] placeholderImage:nil options:SDWebImageScaleDownLargeImages context:@{
      SDWebImageContextImageTransformer: transformer, SDWebImageContextImageThumbnailPixelSize: @(CGSizeMake(200, 200)), SDWebImageContextImageForceDecodePolicy: @(SDImageForceDecodePolicyNever)
    }];
    cell.layer.masksToBounds = YES;
    cell.layer.cornerRadius = 8;
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
  } else if (tableView == self.tableViewOfPodcasting) {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellOfPodcasting"  forIndexPath:indexPath];
  cell.backgroundColor = [UIColor clearColor];
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
  } else {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellOfNotes"  forIndexPath:indexPath];
  cell.backgroundColor = [UIColor clearColor];
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
  }
}




- (void)configWithSongs:(nonnull NSArray<SongModel *> *)songs {
  
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    CGFloat contentx = self.scrollView.contentOffset.x;
//    CGFloat w = scrollView.frame.size.width;
//    CGFloat index = contentx / w;
//    NSInteger select = (NSInteger)(index + 0.5);
//    if (select >= self.segmentControl.numberOfSegments) {
//        select =self.segmentControl.numberOfSegments - 1;
//    }
//    if (self.segmentControl.selectedSegmentIndex != select)
//    {
//        self.segmentControl.selectedSegmentIndex = select;
//    }    //self.segmentControl.selectedSegmentIndex = contentx / [[UIScreen mainScreen] bounds].size.width;
//}



- (void)createSegmentControl {
  self.segmentControl = [[UISegmentedControl alloc] init];
  self.segmentControl.translatesAutoresizingMaskIntoConstraints = NO;
  [self.contentView addSubview:self.segmentControl];
  [NSLayoutConstraint activateConstraints:@[
    [self.segmentControl.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor],
    [self.segmentControl.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:160],
    [self.segmentControl.widthAnchor constraintEqualToConstant:380],
    [self.segmentControl.heightAnchor constraintEqualToConstant:30]
  ]];
  [self.segmentControl insertSegmentWithTitle:@"音乐" atIndex:0 animated:YES];
  [self.segmentControl insertSegmentWithTitle:@"播客" atIndex:1 animated:YES];
  [self.segmentControl insertSegmentWithTitle:@"笔记" atIndex:2 animated:YES];
  self.segmentControl.selectedSegmentIndex = 0;
  //    [self.segmentControl addTarget:self action:@selector(segChanged) forControlEvents:UIControlEventValueChanged];
}



- (void)creatStackView {
  UIStackView* stackView = [[UIStackView alloc] init];
  stackView.translatesAutoresizingMaskIntoConstraints = NO;

  stackView.axis = UILayoutConstraintAxisHorizontal;
  stackView.distribution = UIStackViewDistributionFillEqually;
  stackView.spacing = 10;
  for (int i = 0; i < 4; i++) {
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"b%d.png",i + 1]] forState:UIControlStateNormal];
    [stackView addArrangedSubview:button];
    button.tag = 101 + i;
    [button addTarget:self action:@selector(pressButton:) forControlEvents:UIControlEventTouchUpInside];
  }
  [self.contentView addSubview:stackView];
  [NSLayoutConstraint activateConstraints:@[
    [stackView.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor],
    [stackView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:10],
    [stackView.heightAnchor constraintEqualToConstant:50],
    [stackView.widthAnchor constraintEqualToConstant:300]
  ]];
  UIStackView* stackView2 = [[UIStackView alloc] init];
  stackView2.translatesAutoresizingMaskIntoConstraints = NO;
  stackView2.axis = UILayoutConstraintAxisHorizontal;
  stackView2.distribution = UIStackViewDistributionFillEqually;
  stackView.spacing = 10;
  NSArray* array = @[@"下载", @"收藏", @"历史", @"装扮"];
  for (int i = 0; i < 4; i++) {
    UILabel* label = [[UILabel alloc] init];
    label.text = array[i];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    [stackView2 addArrangedSubview:label];
  }
  [self.contentView addSubview:stackView2];
  [NSLayoutConstraint activateConstraints:@[
    [stackView2.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor],
    [stackView2.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:60],
    [stackView2.heightAnchor constraintEqualToConstant:15],
    [stackView2.widthAnchor constraintEqualToConstant:312]
  ]];

  UIStackView* stackView3 = [[UIStackView alloc] init];
  stackView3.translatesAutoresizingMaskIntoConstraints = NO;

  stackView3.axis = UILayoutConstraintAxisHorizontal;
  stackView3.distribution = UIStackViewDistributionFillEqually;
  stackView3.spacing = 10;
  for (int i = 0; i < 4; i++) {
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"c%d.png",i + 1]] forState:UIControlStateNormal];
    [stackView3 addArrangedSubview:button];
    button.tag = 105 + i;
    [button addTarget:self action:@selector(pressButton:) forControlEvents:UIControlEventTouchUpInside];
  }
  [self.contentView addSubview:stackView3];
  [stackView3 mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerX.equalTo(self.contentView);
    make.top.equalTo(self.contentView).offset(80);
    make.height.mas_equalTo(50);
    make.width.mas_equalTo(300);
  }];
  UIStackView* stackView4 = [[UIStackView alloc] init];
  stackView4.translatesAutoresizingMaskIntoConstraints = NO;
  stackView4.axis = UILayoutConstraintAxisHorizontal;
  stackView4.distribution = UIStackViewDistributionFillEqually;
  stackView.spacing = 10;
  NSArray* array2 = @[@"睡眠", @"书籍", @"设置", @"云盘"];
  for (int i = 0; i < 4; i++) {
    UILabel* label = [[UILabel alloc] init];
    label.text = array2[i];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    [stackView4 addArrangedSubview:label];
  }
  [self.contentView addSubview:stackView4];
  [stackView4 mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerX.equalTo(self.contentView);
    make.top.equalTo(self.contentView).offset(130);
    make.height.mas_equalTo(15);
    make.width.mas_equalTo(312);
  }];
}


- (void)pressButton:(UIButton* )button {
  if (self.buttonClickBlock) {
    self.buttonClickBlock(button);
  }
}




//- (void)configWithSongs:(NSArray<SongModel *> *)songs {
//  self.songs = songs;
//  [_scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
//
//  UIView *lastView = nil;
//  for (int i = 0; i < songs.count; i++) {
//    SongModel *song = songs[i];
//
//    UIView *item = [self songView:song index:i];
//    [_scrollView addSubview:item];
//
//    [item mas_makeConstraints:^(MASConstraintMaker *make) {
//      make.top.bottom.equalTo(self.scrollView);
//      make.width.equalTo(self.scrollView);
//      make.left.equalTo(lastView ? lastView.mas_right : self.scrollView);
//    }];
//    lastView = item;
//  }
//
//  [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
//    make.right.equalTo(lastView);
//  }];
//}
//
//
//- (UIView *)songView:(SongModel *)song index:(NSInteger)index {
//
//  AlbumModel* albumModel = song.album;
//  UIView *view = [[UIView alloc] init];
//  UIImageView *img = [[UIImageView alloc] init];
//  SDImageResizingTransformer *transformer =
//  [SDImageResizingTransformer transformerWithSize:CGSizeMake(200, 200) scaleMode:SDImageScaleModeAspectFill];
//  [img sd_setImageWithURL:[NSURL URLWithString:albumModel.picUrl] placeholderImage:nil options:SDWebImageScaleDownLargeImages context:@{
//    SDWebImageContextImageTransformer: transformer, SDWebImageContextImageThumbnailPixelSize: @(CGSizeMake(200, 200)), SDWebImageContextImageForceDecodePolicy: @(SDImageForceDecodePolicyNever)
//  }];
//  img.layer.cornerRadius = 8;
//  img.clipsToBounds = YES;
//
//  UILabel *title = [[UILabel alloc] init];
//  title.text = [song.name copy];
//
//  UILabel *author = [[UILabel alloc] init];
//  ArtistModel* artist = [song.artists objectAtIndex:0];
//  author.text = [artist.name copy];
//  author.font = [UIFont systemFontOfSize:12];
//
//  UIButton *like = [UIButton buttonWithType:UIButtonTypeCustom];
//  [like setImage:[UIImage imageNamed:(song.isLiked ? @"selectHeart.png" : @"heart.png")] forState:UIControlStateNormal];
//  like.tag = index;
//  [like addTarget:self action:@selector(likeAction:) forControlEvents:UIControlEventTouchUpInside];
//
//  [view addSubview:img];
//  [view addSubview:title];
//  [view addSubview:author];
//  [view addSubview:like];
//
//  [img mas_makeConstraints:^(MASConstraintMaker *make) {
//    make.left.top.equalTo(view).offset(20);
//    make.width.height.mas_equalTo(60);
//  }];
//
//  [title mas_makeConstraints:^(MASConstraintMaker *make) {
//    make.left.equalTo(img.mas_right).offset(10);
//    make.top.equalTo(img);
//  }];
//
//  [author mas_makeConstraints:^(MASConstraintMaker *make) {
//    make.left.equalTo(title);
//    make.top.equalTo(title.mas_bottom).offset(5);
//  }];
//
//  [like mas_makeConstraints:^(MASConstraintMaker *make) {
//    make.centerY.equalTo(img);
//    make.right.equalTo(view).offset(-20);
//    make.width.height.mas_equalTo(30);
//  }];
//
//  return view;
//}
//
//- (void)likeAction:(UIButton *)btn {
//  if (self.likeBlock) {
//    self.likeBlock(btn.tag);
//  }
//}
//
//- (void)pressHeart:(UIButton* )button {
//  if (button.selected == NO) {
//    [button setImage:[UIImage imageNamed:@"heart.png"] forState:UIControlStateNormal];
//    button.selected = YES;
//  } else {
//    button.selected = NO;
//    [button setImage:[UIImage imageNamed:@"selectedHeart.png"] forState:UIControlStateNormal];
//  }
//}


- (void)awakeFromNib {
  [super awakeFromNib];
  // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];

  // Configure the view for the selected state
}



@end



