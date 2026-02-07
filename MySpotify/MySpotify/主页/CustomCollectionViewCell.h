//
//  CustomCollectionViewCell.h
//  MySpotify
//
//  Created by xiaoli pop on 2025/11/20.
//

#import <UIKit/UIKit.h>
#import "SongModel.h"
#import "ArtistModel.h"
#import "CategoryModel.h"
NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, CustomCollectionViewCellType) {
  CustomCollectionViewCellTypeTrack,
  CustomCollectionViewCellTypeArtist,
  CustomCollectionViewCellTypeAlbums,
  CustomCollectionViewCellTypeCategories
};
@interface CustomCollectionViewCell : UICollectionViewCell
//@property (nonatomic, strong)TrackModel* trackModel;
@property (nonatomic, strong)UIImageView* imageView;
@property (nonatomic, strong)UILabel* songNameLabel;
@property (nonatomic, strong)UILabel* artistNameLabel;
@property (nonatomic, strong)UIImageView* artistCoverImageView;
@property (nonatomic, assign)CustomCollectionViewCellType cellType;
- (void)configureWithSongModel:(SongModel* )songModel;
- (void)configureWithAristModel:(ArtistModel* )artistModel;
- (void)configureWithAlbumsModel:(AlbumModel* )albumModel;
- (void)configureWithCategoryModel:(CategoryModel* )categoryModel;
@end

NS_ASSUME_NONNULL_END
