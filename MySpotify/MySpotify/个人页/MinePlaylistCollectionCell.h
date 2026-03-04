//
//  MinePlaylistCollectionCell.h
//  MySpotify
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MinePlaylistCollectionCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
- (void)configWithTitle:(NSString *)title subtitle:(NSString *)subtitle imageURL:(nullable NSString *)url selected:(BOOL)selected;
- (void)playSelectAnimation;
@end

NS_ASSUME_NONNULL_END
