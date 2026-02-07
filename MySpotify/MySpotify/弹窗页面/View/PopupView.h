//
//  PopupView.h
//  MySpotify
//
//  Created by xiaoli pop on 2026/1/23.
//

#import <UIKit/UIKit.h>
@class ArtistModel;
NS_ASSUME_NONNULL_BEGIN

@interface PopupView : UIView
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIImageView* backView;
@property (nonatomic, strong)UIVisualEffectView* blurView;
@property (nonatomic, strong)UIView* darkMaskView;
@property (nonatomic, strong)UILabel* title;
@property (nonatomic, strong)UIScrollView* scrollView;
@property (nonatomic, strong)UILabel* label;
@property (nonatomic, strong)UIButton* linkButton;
- (void)configureWithDetailData:(ArtistModel* )artistModel;
@end

NS_ASSUME_NONNULL_END
