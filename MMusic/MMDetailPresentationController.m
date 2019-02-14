//
//  MMDetailPresentationController.m
//  TransitionAnimation
//
//  Created by 🐙怪兽 on 2018/11/14.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import "MMDetailPresentationController.h"


@interface MMDetailPresentationController ()
@property(nonatomic, strong) UIView *dimmingView; //背景
@end

@implementation MMDetailPresentationController


- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController{
    self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
    if (self) {
        _dimmingView = [[UIView alloc] init];
        [_dimmingView setBackgroundColor:[UIColor colorWithWhite:0.2 alpha:0.8]];
        [_dimmingView setAlpha:0.0];
    }
    return self;
}

//呈现 内容Frame
- (CGRect)frameOfPresentedViewInContainerView{

    UIEdgeInsets padding = UIEdgeInsetsMake(20, 8, 8, 8);;

    CGRect presentedViewFrame = [[UIScreen mainScreen] bounds];
    CGRect containerBounds = [[self containerView] bounds];

    CGFloat whidthOffset = padding.left+padding.right;
    CGFloat heightOffset = padding.top+padding.bottom;
    presentedViewFrame.size = CGSizeMake(CGRectGetWidth(containerBounds)-whidthOffset,CGRectGetHeight(containerBounds)-heightOffset);
    presentedViewFrame.origin.x = padding.left;
    presentedViewFrame.origin.y = padding.top;

    return presentedViewFrame;
}

-  (void)presentationTransitionWillBegin{

    //添加灰色 视图层次
    UIView* containerView = [self containerView];
    UIViewController* presentedViewController = [self presentedViewController];
    [[self dimmingView] setFrame:[containerView bounds]];
    [[self dimmingView] setAlpha:0.0];


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
    [UIView animateWithDuration:0.35 animations:^{
        [[self dimmingView] setAlpha:0];
    }];
}
- (void)dismissalTransitionDidEnd:(BOOL)completed{
    [[self dimmingView] removeFromSuperview];
}


@end
