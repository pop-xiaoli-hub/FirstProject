//
//  CustomCollectionViewCell.m
//  MySpotify
//
//  Created by xiaoli pop on 2025/11/20.
//

#import "CustomCollectionViewCell.h"
#import "Masonry.h"
#import "SongModel.h"
#import "ArtistModel.h"
@implementation CustomCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    self.contentView.backgroundColor =  [UIColor colorWithRed:138/225.0f green:138/225.0f blue:138/225.0f alpha:0.2];
    [self setBaseUI];
  }
  return self;
  
}

- (void)setBaseUI {
  self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
  [self.contentView addSubview:self.imageView];
  self.imageView.layer.masksToBounds = YES;
  self.imageView.contentMode = UIViewContentModeScaleAspectFill;
  self.songNameLabel = [[UILabel alloc] init];
  self.songNameLabel.textColor = [UIColor whiteColor];
  self.songNameLabel.font = [UIFont systemFontOfSize:16];
  [self.contentView addSubview:self.songNameLabel];
  self.songNameLabel.backgroundColor = [UIColor clearColor];
  self.artistNameLabel = [[UILabel alloc] init];
  self.artistNameLabel.textColor = [UIColor lightGrayColor];
  self.artistNameLabel.font = [UIFont systemFontOfSize:14];
  [self.contentView addSubview:self.artistNameLabel];
  self.artistNameLabel.backgroundColor = [UIColor clearColor];
}

- (void)resetUI {
  [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {}];
  [self.songNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {}];
  [self.artistNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {}];
}

- (void)setCellType:(CustomCollectionViewCellType)cellType {
  _cellType = cellType;
  [self resetUI];
  if (cellType == CustomCollectionViewCellTypeTrack) {
    [self setUpTrackUI];
  } else if (cellType == CustomCollectionViewCellTypeArtist) {
    [self setUpArtistUI];
  } else if (cellType == CustomCollectionViewCellTypeAlbums) {
    [self setUpAlbumsUI];
  } else {
    [self setUpCategoriesUI];
  }
}

- (void)setUpCategoriesUI {
  self.songNameLabel.hidden = YES;
  self.artistNameLabel.hidden = YES;
  self.imageView.layer.cornerRadius = 10;
  [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(self.contentView.mas_left);
      make.top.equalTo(self.contentView.mas_top);
      make.width.height.equalTo(self.contentView);
  }];
}

- (void)setUpAlbumsUI {
  self.songNameLabel.hidden = YES;
  self.artistNameLabel.hidden = YES;
  self.imageView.layer.cornerRadius = 10;
  [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(self.contentView.mas_left);
      make.top.equalTo(self.contentView.mas_top);
      make.width.height.equalTo(self.contentView);
  }];
}


- (void)setUpTrackUI {
  self.songNameLabel.hidden = NO;
  self.artistNameLabel.hidden = NO;
  self.imageView.layer.cornerRadius = 8;
  [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(self.contentView.mas_left);
      make.top.equalTo(self.contentView.mas_top);
      make.height.mas_equalTo(self.contentView.mas_height);
      make.width.mas_equalTo(self.contentView.mas_height);
  }];
  [self.artistNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(self.songNameLabel);
      make.top.equalTo(self.songNameLabel.mas_bottom).offset(10);
      make.width.mas_equalTo(200);
      make.height.mas_equalTo(20);
  }];
  [self.songNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(self.imageView.mas_right).offset(10);
      make.top.equalTo(self.imageView.mas_top).offset(10);
      make.width.mas_equalTo(200);
      make.height.mas_equalTo(25);
  }];
}

- (void)setUpArtistUI {
  self.songNameLabel.hidden = YES;
  self.artistNameLabel.hidden = YES;
  self.imageView.layer.cornerRadius = 10;
  [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.left.equalTo(self.contentView.mas_left);
      make.top.equalTo(self.contentView.mas_top);
      make.height.mas_equalTo(180);
      make.width.mas_equalTo(180);
  }];
}


- (void)configureWithCategoryModel:(CategoryModel *)categoryModel {
  
}

- (void)configureWithSongModel:(SongModel *)songModel {
  NSLog(@"songModel:name:%@ image:%@", songModel.name, songModel.image);
 // self.imageView.image = songModel.image;
  self.songNameLabel.text = [songModel.name copy];
  ArtistModel* artist = [songModel.artists objectAtIndex:0];
  self.artistNameLabel.text = [artist.name copy];
}

- (void)configureWithAristModel:(ArtistModel *)artistModel {
  NSLog(@"歌手%@的id为%lld", artistModel.name, artistModel.id);
}

- (void)configureWithAlbumsModel:(AlbumModel *)albumModel {
  
}



@end
