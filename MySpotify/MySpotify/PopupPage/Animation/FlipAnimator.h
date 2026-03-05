//
//  FlipAnimator.h
//  MySpotify
//
//  Created by xiaoli pop on 2026/1/23.
//

#import <Foundation/Foundation.h>
#import "PopupTransitionDelegate.h"
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface FlipAnimator : NSObject<UIViewControllerAnimatedTransitioning>
@property (nonatomic, assign) BOOL presenting;

@end

NS_ASSUME_NONNULL_END
