//
//  CommentHeaderView.h
//  MySpotify
//
//  Created by xiaoli pop on 2026/1/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class SongModel;
@interface CommentHeaderView : UIView
@property (nonatomic, strong)UIImageView* imageView;
@property (nonatomic, strong)UILabel* label;
- (void)configureWithModel:(SongModel* )songModel;
@end

NS_ASSUME_NONNULL_END
