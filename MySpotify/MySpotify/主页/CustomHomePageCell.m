//
//  CustomHomePageCell.m
//  MySpotify
//
//  Created by xiaoli pop on 2025/11/19.
//

#import "CustomHomePageCell.h"
#import "Masonry.h"
#import "CustomCollectionViewCell.h"
#import "SongModel.h"
#import "SDWebImage/SDWebImage.h"
#import "RecommendedSongsItemModel.h"
#import <SDWebImageManager.h>
#import "AlbumModel.h"
#import "ArtistModel.h"

@implementation CustomHomePageCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    if ([reuseIdentifier isEqualToString:@"cell01"]) {
      UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
      layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
      layout.itemSize = CGSizeMake(340, 80);
      layout.minimumLineSpacing = 5;
      self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
      self.collectionView.backgroundColor = [UIColor clearColor];
      self.collectionView.showsHorizontalScrollIndicator = NO;
      self.collectionView.scrollEnabled = YES;
      self.collectionView.pagingEnabled = NO;

      self.collectionView.delegate = self;
      self.collectionView.dataSource = self;
      [self.collectionView registerClass:[CustomCollectionViewCell class] forCellWithReuseIdentifier:@"CollectionViewCell01"];
      [self.contentView addSubview:self.collectionView];
      [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
              make.top.equalTo(self.contentView.mas_top).offset(5);
              make.height.mas_equalTo(80);
              make.width.mas_equalTo(self.contentView.mas_width);
              make.left.equalTo(self.contentView);
      }];
    } else if ([reuseIdentifier isEqualToString:@"cell02"]) {
      self.artistsLabel = [[UILabel alloc] init];
      self.artistsLabel.textColor = [UIColor whiteColor];
      self.artistsLabel.backgroundColor =  [UIColor colorWithRed:138/225.0f green:138/225.0f blue:138/225.0f alpha:0.1];
      [self.contentView addSubview:self.artistsLabel];
      [self.artistsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
              make.top.equalTo(self.contentView.mas_top).offset(5);
              make.bottom.equalTo(self.contentView.mas_bottom).offset(-5);
              make.width.mas_equalTo(200);
              make.left.equalTo(self.contentView).offset(5);
      }];
      self.artistsLabel.textAlignment = NSTextAlignmentLeft;
    } else if ([reuseIdentifier isEqualToString:@"cell03"]){
      UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
      layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
      layout.itemSize = CGSizeMake(180, 240);
      layout.minimumLineSpacing = 10;
      self.collectionViewOfArtists = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
      self.collectionViewOfArtists.backgroundColor = [UIColor clearColor];
      self.collectionViewOfArtists.showsHorizontalScrollIndicator = NO;
      self.collectionViewOfArtists.scrollEnabled = YES;
      self.collectionViewOfArtists.pagingEnabled = NO;
      self.collectionViewOfArtists.delegate = self;
      self.collectionViewOfArtists.dataSource = self;
      [self.collectionViewOfArtists registerClass:[CustomCollectionViewCell class] forCellWithReuseIdentifier:@"CollectionViewCell02"];
      [self.contentView addSubview:self.collectionViewOfArtists];
      [self.collectionViewOfArtists mas_makeConstraints:^(MASConstraintMaker *make) {
          make.top.equalTo(self.contentView.mas_top);
          make.height.mas_equalTo(250);
          make.left.equalTo(self.contentView);
          make.right.equalTo(self.contentView).offset(5);
      }];
    } else if ([reuseIdentifier isEqualToString:@"cell04"]) {
      self.commendLabel = [[UILabel alloc] init];
      self.commendLabel.textColor = [UIColor whiteColor];
      self.commendLabel.backgroundColor =  [UIColor colorWithRed:138/225.0f green:138/225.0f blue:138/225.0f alpha:0.1];
      [self.contentView addSubview:self.commendLabel];
      [self.commendLabel mas_makeConstraints:^(MASConstraintMaker *make) {
              make.top.equalTo(self.contentView.mas_top).offset(5);
              make.bottom.equalTo(self.contentView.mas_bottom).offset(-5);
              make.width.mas_equalTo(200);
              make.left.equalTo(self.contentView).offset(5);
      }];
      self.commendLabel.textAlignment = NSTextAlignmentLeft;
    } else if ([reuseIdentifier isEqualToString:@"cell05"]) {
      UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
      layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
      layout.itemSize = CGSizeMake(200, 280);
      layout.minimumLineSpacing = 15;
      self.collectionViewOfAlbums = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
      self.collectionViewOfAlbums.backgroundColor = [UIColor clearColor];
      self.collectionViewOfAlbums.showsHorizontalScrollIndicator = NO;
      self.collectionViewOfAlbums.scrollEnabled = YES;
      self.collectionViewOfAlbums.pagingEnabled = NO;
      self.collectionViewOfAlbums.delegate = self;
      self.collectionViewOfAlbums.dataSource = self;
      [self.collectionViewOfAlbums registerClass:[CustomCollectionViewCell class] forCellWithReuseIdentifier:@"CollectionViewCell03"];
      [self.contentView addSubview:self.collectionViewOfAlbums];
      [self.collectionViewOfAlbums mas_makeConstraints:^(MASConstraintMaker *make) {
          make.top.equalTo(self.contentView.mas_top);
          make.height.mas_equalTo(280);
          make.left.equalTo(self.contentView);
          make.right.equalTo(self.contentView).offset(5);
      }];
    } else if ([reuseIdentifier isEqualToString:@"cell06"]) {
      self.categoryLabel = [[UILabel alloc] init];
      self.categoryLabel.textColor = [UIColor whiteColor];
      self.categoryLabel.backgroundColor =  [UIColor colorWithRed:138/225.0f green:138/225.0f blue:138/225.0f alpha:0.1];
      [self.contentView addSubview:self.categoryLabel];
      [self.categoryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
              make.top.equalTo(self.contentView.mas_top).offset(5);
              make.bottom.equalTo(self.contentView.mas_bottom).offset(-5);
              make.width.mas_equalTo(200);
              make.left.equalTo(self.contentView).offset(5);
      }];
      self.categoryLabel.textAlignment = NSTextAlignmentLeft;
    } else if ([reuseIdentifier isEqualToString:@"cell07"]) {
      UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
      layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
      layout.itemSize = CGSizeMake(200, 200);
      layout.minimumLineSpacing = 15;
      self.collectionVeiwOfCategories = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
      self.collectionVeiwOfCategories.backgroundColor = [UIColor clearColor];
      self.collectionVeiwOfCategories.showsHorizontalScrollIndicator = NO;
      self.collectionVeiwOfCategories.scrollEnabled = YES;
      self.collectionVeiwOfCategories.pagingEnabled = NO;
      self.collectionVeiwOfCategories.delegate = self;
      self.collectionVeiwOfCategories.dataSource = self;
      [self.collectionVeiwOfCategories registerClass:[CustomCollectionViewCell class] forCellWithReuseIdentifier:@"CollectionViewCell04"];
      [self.contentView addSubview:self.collectionVeiwOfCategories];
      [self.collectionVeiwOfCategories mas_makeConstraints:^(MASConstraintMaker *make) {
          make.top.equalTo(self.contentView.mas_top);
          make.height.mas_equalTo(200);
          make.left.equalTo(self.contentView);
          make.right.equalTo(self.contentView).offset(5);
      }];
    }
  }
  return self;
}

- (void)setArrayOfRecommendedSongs:(NSArray *)arrayOfRecommendedSongs {
  _arrayOfRecommendedSongs = arrayOfRecommendedSongs;
  [self.collectionView reloadData];
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.collectionView setContentOffset:CGPointZero animated:NO];
  });
}

- (void)setArrayOfRecommendedCategories:(NSArray *)arrayOfRecommendedCategories {
  _arrayOfRecommendedCategories = arrayOfRecommendedCategories;
  [self.collectionVeiwOfCategories reloadData];
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.collectionVeiwOfCategories setContentOffset:CGPointZero animated:NO];
  });
}



- (void)setArrayOfRecommendedArtists:(NSArray *)arrayOfRecommendedArtists {
  _arrayOfRecommendedArtists = arrayOfRecommendedArtists;
  [self.collectionViewOfArtists reloadData];
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.collectionViewOfArtists setContentOffset:CGPointZero animated:NO];
  });
}

- (void)setArrayOfRecommendedAlbums:(NSArray *)arrayOfRecommendedAlbums {
  _arrayOfRecommendedAlbums = arrayOfRecommendedAlbums;
  [self.collectionViewOfAlbums reloadData];
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.collectionViewOfAlbums setContentOffset:CGPointZero animated:NO];
  });
}








- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  if (collectionView == self.collectionView) {
    return self.arrayOfRecommendedSongs.count;
  }
  if (collectionView == self.collectionViewOfArtists) {
    return self.arrayOfRecommendedArtists.count;
  }
  if (collectionView == self.collectionViewOfAlbums) {
    return self.arrayOfRecommendedAlbums.count;
  }
  if (collectionView == self.collectionVeiwOfCategories) {
    return self.arrayOfRecommendedCategories.count;
  }
  return 0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  if (collectionView == self.collectionView) {
    if (self.itemSelectedBlock) {
      self.itemSelectedBlock(indexPath);
    }
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    [UIView animateWithDuration:0.15 animations:^{
        cell.transform = CGAffineTransformMakeScale(1.05, 1.05);
      } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
          cell.transform = CGAffineTransformIdentity;
        }];
      }];
    if ([self.delegate respondsToSelector:@selector(homePageCell:withReuseIdentifier:didSelectIndexPath:)]) {
      [self.delegate homePageCell:cell withReuseIdentifier:@"song" didSelectIndexPath:indexPath];
    }
  } else if (collectionView == self.collectionViewOfArtists) {
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    [UIView animateWithDuration:0.15 animations:^{
        cell.transform = CGAffineTransformMakeScale(1.05, 1.05);
      } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
          cell.transform = CGAffineTransformIdentity;
        }];
      }];
    if ([self.delegate respondsToSelector:@selector(homePageCell:withReuseIdentifier:didSelectIndexPath:)]) {
      [self.delegate homePageCell:cell withReuseIdentifier:@"artist" didSelectIndexPath:indexPath];
    }
  } else if (collectionView == self.collectionViewOfAlbums) {
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    [UIView animateWithDuration:0.15 animations:^{
        cell.transform = CGAffineTransformMakeScale(1.05, 1.05);
      } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
          cell.transform = CGAffineTransformIdentity;
          if ([self.delegate respondsToSelector:@selector(homePageCell:withReuseIdentifier:didSelectIndexPath:)]) {
//            [self.delegate homePageCell:cell didSelectIndexPath:indexPath];
            [self.delegate homePageCell:cell withReuseIdentifier:@"album" didSelectIndexPath:indexPath];
          }
        }];
      }];
  } else {
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    [UIView animateWithDuration:0.15 animations:^{
        cell.transform = CGAffineTransformMakeScale(1.05, 1.05);
      } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
          cell.transform = CGAffineTransformIdentity;
        }];
      }];
  }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  if (collectionView == self.collectionView) {
    CustomCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewCell01" forIndexPath:indexPath];
    cell.cellType = CustomCollectionViewCellTypeTrack;
    RecommendedSongsItemModel* item = [self.arrayOfRecommendedSongs objectAtIndex:indexPath.row];
    SongModel* songModel = item.song;
    NSLog(@"歌曲ID：%lld", songModel.id);
    AlbumModel* albumModel = songModel.album;
    [cell configureWithSongModel:songModel];
    SDImageResizingTransformer *transformer =
    [SDImageResizingTransformer transformerWithSize:CGSizeMake(200, 200) scaleMode:SDImageScaleModeAspectFill];
    /*
     创建一个图片转换器transformer,用于在图片加载后对UIImage做重新绘制/缩放的类，在图片被解码后将图片重新渲染成指定尺寸
     */
     [cell.imageView sd_setImageWithURL:[NSURL URLWithString:albumModel.picUrl] placeholderImage:nil options:SDWebImageScaleDownLargeImages context:@{
      SDWebImageContextImageTransformer: transformer, SDWebImageContextImageThumbnailPixelSize: @(CGSizeMake(200, 200)), SDWebImageContextImageForceDecodePolicy: @(SDImageForceDecodePolicyNever)
    }];
    cell.layer.masksToBounds = YES;
    cell.layer.cornerRadius = 8;
    return cell;
  } else if (collectionView == self.collectionViewOfArtists){
    CustomCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewCell02" forIndexPath:indexPath];
    cell.cellType = CustomCollectionViewCellTypeArtist;
    ArtistModel* model = [self.arrayOfRecommendedArtists objectAtIndex:indexPath.row];
    NSString *url = model.picUrl;
    NSRange range = [url rangeOfString:@"?"];
    if (range.location != NSNotFound) {
        url = [url substringToIndex:range.location];
    }
    url = [NSString stringWithFormat:@"%@?param=200y200", url];
    model.picUrl = url;
    [cell configureWithAristModel:model];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:model.picUrl] placeholderImage:nil options:SDWebImageRetryFailed];

    cell.layer.masksToBounds = YES;
    cell.layer.cornerRadius = 10;

    return cell;

  } else if (collectionView == self.collectionViewOfAlbums) {
    CustomCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewCell03" forIndexPath:indexPath];
    cell.cellType = CustomCollectionViewCellTypeAlbums;
    AlbumModel* model = [self.arrayOfRecommendedAlbums objectAtIndex:indexPath.row];
    NSLog(@"3%@ %@", model.name, model.coverImgUrl);
    NSString* url = model.coverImgUrl;
    NSRange range = [url rangeOfString:@"?"];
    if (range.location != NSNotFound) {
        url = [url substringToIndex:range.location];
    }
    url = [NSString stringWithFormat:@"%@?param=200y200", url];
    model.coverImgUrl = url;
    [cell configureWithAlbumsModel:model];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:model.coverImgUrl] placeholderImage:nil options:SDWebImageRetryFailed];

    cell.layer.masksToBounds = YES;
    cell.layer.cornerRadius = 10;
    return cell;
  } else if (collectionView == self.collectionVeiwOfCategories) {
    CustomCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewCell04" forIndexPath:indexPath];
    cell.cellType = CustomCollectionViewCellTypeCategories;
    CategoryModel* model = [self.arrayOfRecommendedCategories objectAtIndex:indexPath.row];
    NSString* url = model.picUrl;
    NSRange range = [url rangeOfString:@"?"];
    if (range.location != NSNotFound) {
        url = [url substringToIndex:range.location];
    }
    url = [NSString stringWithFormat:@"%@?param=200y200", url];
    model.picUrl = url;
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:model.picUrl] placeholderImage:nil options:SDWebImageRetryFailed];
    cell.layer.masksToBounds = YES;
    cell.layer.cornerRadius = 10;
    return cell;
  }
  return [UICollectionViewCell new];
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

/*
 TrackModel* model = [self.trackList objectAtIndex:indexPath.row];
 NSString* urlString = [NSString stringWithFormat:@"https://api.spotify.com/v1/albums/%@", model.id];
 NSURL* url = [NSURL URLWithString:urlString];
 [cell.imageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"placeholder"]];
 */
