//
//  MMPopupAnimator.m
//  TransitionAnimation
//
//  Created by 🐙怪兽 on 2018/11/12.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import "MMPopupAnimator.h"

@implementation MMPopupAnimator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return 0.5;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{

    //呈现
    if (self.presenting) {
        UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        CGRect finalFrame = [transitionContext finalFrameForViewController:toVC];

        [toVC.view setFrame:self.startFrame];
        [transitionContext.containerView addSubview:toVC.view];
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0.0
             usingSpringWithDamping:0.65
              initialSpringVelocity:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [toVC.view setFrame:finalFrame];
                         }
                         completion:^(BOOL finished) {
                             [transitionContext completeTransition:YES];
                         }];
    }else{

        //dismiss
        UIViewController *from = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
//        NSLog(@"From frame =%@",NSStringFromCGRect(from.view.frame));
//        NSLog(@"start frame =%@",NSStringFromCGRect(self.startFrame));
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0.0
             usingSpringWithDamping:0.65
              initialSpringVelocity:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [from.view setAlpha:0];
                             [from.view setFrame:self.startFrame];
                         }
                         completion:^(BOOL finished) {
                             [from.view removeFromSuperview];
                             [transitionContext completeTransition:YES];
                         }];
    }
}
@end
