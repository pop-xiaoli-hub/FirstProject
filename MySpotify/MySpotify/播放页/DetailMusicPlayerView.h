//
//  DetailMusicPlayerView.h
//  MySpotify
//
//  Created by xiaoli pop on 2025/12/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class SongPlayingModel;
@interface DetailMusicPlayerView : UIView

@property (nonatomic, strong)UIImageView* imageView;
@property (nonatomic, strong)UILabel* songNameLabel;
@property (nonatomic, strong)UIButton* previousButton;
@property (nonatomic, strong)UIButton* nextButton;
@property (nonatomic, strong)UIButton* switchButton;
@property (nonatomic, strong)UISlider* slider;
@property (nonatomic, strong)UIStackView* stackView;
@property (nonatomic, strong)UIButton* downloadButton;
@property (nonatomic, copy) void (^buttonClickBlock)(UIButton*);
- (void)configureWithModel:(SongPlayingModel* )model;
- (void)resetControlsWithDownloaded:(BOOL)isDownloaded;
@end

NS_ASSUME_NONNULL_END
