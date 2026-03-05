//
//  PopupTransitionDelegate.m
//  MySpotify
//
//  Created by xiaoli pop on 2026/1/23.
//

#import "PopupTransitionDelegate.h"
#import "FlipAnimator.h"
#import "BlurPresentationController.h"

@implementation PopupTransitionDelegate {
    FlipAnimator *_animator;
}

- (instancetype)init {
    if (self = [super init]) {
        _animator = [FlipAnimator new];
    }
    return self;
}

- (UIPresentationController *) presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    return [[BlurPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
}

- (id<UIViewControllerAnimatedTransitioning>)
animationControllerForPresentedController:(UIViewController *)presented
presentingController:(UIViewController *)presenting
sourceController:(UIViewController *)source {

    _animator.presenting = YES;
    return _animator;
}

- (id<UIViewControllerAnimatedTransitioning>) animationControllerForDismissedController:(UIViewController *)dismissed {
    _animator.presenting = NO;
    return _animator;
}

@end
