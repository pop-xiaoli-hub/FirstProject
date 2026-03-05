//
//  MyCollectionViewLayout.h
//  MySpotify
//
//  Created by xiaoli pop on 2025/12/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN



@protocol MyCollectionViewLayoutDelegate <NSObject>
@required
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)layout heightForItemAtIndexPath:(NSIndexPath *)indexPath itemWidth:(CGFloat)width;
@end

@interface MyCollectionViewLayout : UICollectionViewLayout

@property (nonatomic, assign) NSInteger columnCount;
@property (nonatomic, assign) CGFloat columnMargin;
@property (nonatomic, assign) CGFloat rowMargin;
@property (nonatomic, assign) UIEdgeInsets sectionInset;
@property (nonatomic, weak) id<MyCollectionViewLayoutDelegate> delegate;

@end
NS_ASSUME_NONNULL_END
