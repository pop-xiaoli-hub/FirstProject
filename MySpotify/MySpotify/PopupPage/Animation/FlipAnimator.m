//
//  FlipAnimator.m
//  MySpotify
//
//  Created by xiaoli pop on 2026/1/23.
//

#import "FlipAnimator.h"
#import "BlurPresentationController.h"

@implementation FlipAnimator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
  return 0.7;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
  UIView *container = transitionContext.containerView;
  UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
  UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
  BOOL presenting = self.presenting;
  UIView *view = presenting ? toView : fromView;
  CATransform3D perspective = CATransform3DIdentity;
  perspective.m34 = -1.0 / 500;
  container.layer.sublayerTransform = perspective;
  if (presenting) {
    // 初始状态：翻转到 -90°，缩放 0.95
    view.layer.transform = CATransform3DMakeRotation(-M_PI_2, 1, 0, 0);
    view.layer.transform = CATransform3DScale(view.layer.transform, 0.95, 0.95, 1);
    // 阴影
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOpacity = 0.3;
    view.layer.shadowOffset = CGSizeMake(0, 5);
    view.layer.shadowRadius = 10;

    [container addSubview:view];
  }
  [UIView animateKeyframesWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
    // 旧视图翻转 -45度
    [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.5 animations:^{
      fromView.layer.transform = CATransform3DMakeRotation(M_PI_4, 1, 0, 0);
    }];
    // 新视图翻转到 0° 并恢复缩放
    [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.5 animations:^{
      view.layer.transform = CATransform3DIdentity;
      view.layer.transform = CATransform3DScale(view.layer.transform, 1, 1, 1);
      view.layer.shadowOpacity = 0.5;
    }];
  } completion:^(BOOL finished) {
    // 动画完成后再显示毛玻璃
    if (presenting) {
      UIViewController *vc = (UIViewController *)view.nextResponder;
      if ([vc isKindOfClass:[UIViewController class]]) {
        UIPresentationController *presentationController = vc.presentationController;
        if ([presentationController isKindOfClass:[BlurPresentationController class]]) {
          BlurPresentationController *blurPC = (BlurPresentationController *)presentationController;
          [UIView animateWithDuration:0.2 animations:^{
            blurPC.blurView.alpha = 1;
          }];
        }
      }
    }
    [transitionContext completeTransition:YES];
  }];
}

@end
