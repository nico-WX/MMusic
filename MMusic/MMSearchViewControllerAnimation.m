//
//  MMSearchViewControllerAnimation.m
//  SearchController
//
//  Created by 🐙怪兽 on 2018/11/22.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import "MMSearchViewControllerAnimation.h"

@implementation MMSearchViewControllerAnimation

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return 0;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    if (_present) {
        UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
        UIView *containerView = [transitionContext containerView];


        CGRect finalFrame = [transitionContext finalFrameForViewController:toVC];
        CGRect bounds = [[UIScreen mainScreen] bounds];
        [toView setFrame:bounds];
        [toView setAlpha:0];
        [containerView addSubview:toView];

        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            [toView setFrame:finalFrame];
            [toView setAlpha:1];
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }else{
        UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];

        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            [fromVC.view setAlpha:0];
        } completion:^(BOOL finished) {
            [fromVC.view removeFromSuperview];
            [transitionContext completeTransition:YES];
        }];
    }
}
@end
