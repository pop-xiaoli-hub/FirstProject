//
//  BlurPresentationController.m
//  MySpotify
//
//  Created by xiaoli pop on 2026/1/23.
//
#import "BlurPresentationController.h"
#import <Masonry.h>

@interface BlurPresentationController ()

@end

@implementation BlurPresentationController

- (void)presentationTransitionWillBegin {
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    self.blurView = [[UIVisualEffectView alloc] initWithEffect:effect];
    self.blurView.frame = self.containerView.bounds;
    self.blurView.alpha = 0;
    [self.containerView insertSubview:self.blurView atIndex:0];
}

- (void)dismissalTransitionWillBegin {
  self.blurView.alpha = 0;
}

@end


