//
//  MMPopupAnimator.m
//  ScrollPage
//
//  Created by 🐙怪兽 on 2018/11/9.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import "MMPopupAnimator.h"

@implementation MMPopupAnimator


- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return 0.8f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    UIViewController *toVC =  [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];

    CGRect screenBounds = [UIScreen mainScreen].bounds;
    CGRect finalFrame = [transitionContext finalFrameForViewController:toVC];
    toVC.view.frame = CGRectOffset(finalFrame, CGRectGetMaxY(fromVC.view.frame), CGRectGetWidth(screenBounds));

    [transitionContext.containerView addSubview:toVC.view];

    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0.0
         usingSpringWithDamping:0.8
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         toVC.view.frame = finalFrame;
                     }
                     completion:^(BOOL finished) {
                         [transitionContext completeTransition:YES];
    }];
}


@end
