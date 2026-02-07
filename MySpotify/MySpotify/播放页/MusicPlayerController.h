//
//  MusicPlayerController.h
//  MySpotify
//
//  Created by xiaoli pop on 2025/12/6.
//

#import <UIKit/UIKit.h>
#import "AVFoundation/AVFoundation.h"
NS_ASSUME_NONNULL_BEGIN
@class MusicPlayerView;
@interface MusicPlayerController : UIViewController
@property (nonatomic, strong)NSMutableArray* musicPlayList;
@property (nonatomic, strong)MusicPlayerView* myView;
@property (nonatomic, assign)NSInteger currentIndex;
@property (nonatomic, assign)BOOL isProgrammaticScroll;
@property (nonatomic, strong)AVPlayerItem* item;
@property (nonatomic, strong)AVPlayer* player;
@property (nonatomic, assign)BOOL isplaying;
@property (nonatomic, strong, nullable)id timeObserver;
- (void)pressButtonOfSwitch:(UIButton* )button;
@end

NS_ASSUME_NONNULL_END
