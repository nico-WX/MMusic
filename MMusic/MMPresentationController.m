//
//  MMPresentationController.m
//  TransitionAnimation
//
//  Created by 🐙怪兽 on 2018/11/14.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import "MMPresentationController.h"

@interface MMPresentationController ()
@property(nonatomic, strong)UIView *dimmingView; //背景
@end

@implementation MMPresentationController


- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController{
    self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
    if (self) {
        _dimmingView = [[UIView alloc] init];
        [_dimmingView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.7]];
        [_dimmingView setAlpha:0.0];
    }
    return self;
}

//呈现 内容Frame
- (CGRect)frameOfPresentedViewInContainerView{
    CGFloat x = 10;
    CGFloat y = 20;
    CGRect presentedViewFrame = [[UIScreen mainScreen] bounds];
    CGRect containerBounds = [[self containerView] bounds];

    presentedViewFrame.size = CGSizeMake(CGRectGetWidth(containerBounds)-x*2,containerBounds.size.height-y*2);
    presentedViewFrame.origin.x = x;
    presentedViewFrame.origin.y = y;

    return presentedViewFrame;
}

-  (void)presentationTransitionWillBegin{

    //添加灰色 视图层次
    UIView* containerView = [self containerView];
    UIViewController* presentedViewController = [self presentedViewController];
    [[self dimmingView] setFrame:[containerView bounds]];
    [[self dimmingView] setAlpha:0.0];

    //
    [containerView setNeedsUpdateConstraints];

    [containerView addSubview:self.dimmingView];

    // Set up the animations for fading in the dimming view.
    if([presentedViewController transitionCoordinator]) {
        [[presentedViewController transitionCoordinator]
         animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>
                                      context) {
             // Fade in the dimming view.
             [[self dimmingView] setAlpha:1.0];
         } completion:nil];
    }
    else {
        [[self dimmingView] setAlpha:1.0];
    }
}

- (void)dismissalTransitionWillBegin{
    [UIView animateWithDuration:0.5 animations:^{
        [[self dimmingView] setAlpha:0];
    }];
}
- (void)dismissalTransitionDidEnd:(BOOL)completed{
    [[self dimmingView] removeFromSuperview];
}

@end
