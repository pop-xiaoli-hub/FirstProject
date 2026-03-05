//
//  FloatingPlayerView.h
//  MySpotify
//
//  Created by xiaoli pop on 2025/12/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FloatingPlayerView : UIView
@property (nonatomic, strong)UIButton* buttonOfPlayerSwitches;
@property (nonatomic, strong)UIVisualEffectView* blurView;
@property (nonatomic, strong)UIImageView* trackHeaderView;
@property (nonatomic, strong)UILabel* trackNameLabel;
@property (nonatomic, strong)UILabel* trackArtistNameLabel;

- (void)createPlayerView;
- (void)layoutNewFrame;
@end

NS_ASSUME_NONNULL_END
