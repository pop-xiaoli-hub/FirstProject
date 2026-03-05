//
//  CustomHomePageCell.h
//  MySpotify
//
//  Created by xiaoli pop on 2025/11/19.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@class CustomCollectionViewCell;
@protocol CustomHomePageCellDelegate <NSObject>

- (void)homePageCell:(UICollectionViewCell* )cell withReuseIdentifier:(NSString* )reuseIdentifier didSelectIndexPath:(NSIndexPath* )indexPath;

@end

@interface CustomHomePageCell : UITableViewCell<UICollectionViewDelegate, UICollectionViewDataSource>
@property(nonatomic, strong)UICollectionView* collectionView;
@property(nonatomic, strong)UIView* containerView;
@property (nonatomic, strong)UICollectionView* collectionViewOfArtists;
@property (nonatomic, strong)UILabel* artistsLabel;
@property (nonatomic, copy)void(^itemSelectedBlock)(NSIndexPath* collectionViewIndexPath);
@property (nonatomic, strong)NSArray* arrayOfArtists;
@property (nonatomic, strong)UILabel* commendLabel;
@property (nonatomic, strong)UICollectionView* collectionViewOfAlbums;
@property (nonatomic, weak)id<CustomHomePageCellDelegate> delegate;
@property (nonatomic, strong)NSArray* arrayOfRecommendedSongs;
@property (nonatomic, strong)NSArray* arrayOfRecommendedArtists;
@property (nonatomic, strong)NSArray* arrayOfRecommendedAlbums;
@property (nonatomic, strong)NSArray* arrayOfRecommendedCategories;
@property (nonatomic, strong)UICollectionView* collectionVeiwOfCategories;
@property (nonatomic, strong)UILabel* categoryLabel;
@end

NS_ASSUME_NONNULL_END
