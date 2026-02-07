//
//  MusicPlayerView.h
//  MySpotify
//
//  Created by xiaoli pop on 2025/12/6.
//

#import <UIKit/UIKit.h>
#import "DetailMusicPlayerView.h"
NS_ASSUME_NONNULL_BEGIN

@interface MusicPlayerView : UIView
@property (nonatomic, strong)DetailMusicPlayerView* leftPage;
@property (nonatomic, strong)DetailMusicPlayerView* centerPage;
@property (nonatomic, strong)DetailMusicPlayerView* rightPage;
@property (nonatomic, strong)UIScrollView* scrollView;
@end

NS_ASSUME_NONNULL_END
