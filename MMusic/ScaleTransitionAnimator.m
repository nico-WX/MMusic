//
//  ScaleTransitionAnimator.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/4.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import "ScaleTransitionAnimator.h"

@implementation ScaleTransitionAnimator

- (void)animateTransition:(nonnull id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    
}

- (NSTimeInterval)transitionDuration:(nullable id<UIViewControllerContextTransitioning>)transitionContext {
    return 1.0f;
}

@end
