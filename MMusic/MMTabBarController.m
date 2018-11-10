//
//  MMTabBarController.m
//
//  Created by 🐙怪兽 on 2018/11/8.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import "MMTabBarController.h"

@interface MMTabBarController ()
@property(nonatomic, strong)UIViewController<MMTabbarControllerPopupDelegate> *popupViewController;
@property(nonatomic, strong)UIVisualEffectView *visualEffectView;

@property(nonatomic, assign)CGRect popupFrame;
@property(nonatomic, strong)UIImpactFeedbackGenerator *impactFeedback;
@end

@implementation MMTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tabBar setHidden:YES];

    self.impactFeedback = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleHeavy];

    self.popupFrame = ({
        CGFloat spacing = 8.0f;
        CGFloat x = spacing;
        CGFloat w = CGRectGetWidth(self.view.frame)-(spacing*2);
        CGFloat h = 55.0f;
        CGFloat y = CGRectGetMaxY(self.view.frame)-(h+spacing);

        CGRectMake(x, y, w, h);
    });

    self.visualEffectView = ({
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *view = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        view.frame = self.popupFrame;
        [view.layer setCornerRadius:8.0f];
        [view.layer setMasksToBounds:YES];
        view;
    });

    [self.view addSubview:self.visualEffectView];


    //手势
    ({
        UISwipeGestureRecognizer *rightSwipe = [UISwipeGestureRecognizer new];
        UISwipeGestureRecognizer *leftSwipe = [UISwipeGestureRecognizer new];
        UISwipeGestureRecognizer *upSwipe   = [UISwipeGestureRecognizer new];
        UISwipeGestureRecognizer *downSwipe = [UISwipeGestureRecognizer new];

        [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
        [leftSwipe setDirection:UISwipeGestureRecognizerDirectionLeft];
        [upSwipe setDirection:UISwipeGestureRecognizerDirectionUp];
        [downSwipe setDirection:UISwipeGestureRecognizerDirectionDown];

        [leftSwipe addTarget:self action:@selector(handleSwipeGesture:)];
        [rightSwipe addTarget:self action:@selector(handleSwipeGesture:)];
        [upSwipe addTarget:self action:@selector(handleSwipeGesture:)];
        [downSwipe addTarget:self action:@selector(handleSwipeGesture:)];

        [self.view addGestureRecognizer:leftSwipe];
        [self.view addGestureRecognizer:rightSwipe];
        //效果视图
        [self.visualEffectView addGestureRecognizer:upSwipe];
        [self.visualEffectView addGestureRecognizer:downSwipe];
    });
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    if (CGRectGetHeight(self.tabBar.frame) > 49) {
        self.popupFrame = CGRectOffset(self.popupFrame, 0, - 34);  //标准为 34 点
        [self.visualEffectView setFrame:self.popupFrame];
    }
}


- (void)handleSwipeGesture:(UISwipeGestureRecognizer*)swipeGesture {

    //打开popupView 时, 拦截左右切换VC 手势(判断 当前popupView 高度)
    CGFloat oh = CGRectGetHeight(self.popupViewController.view.frame);
    CGFloat ch = CGRectGetHeight(self.popupFrame);

    if (swipeGesture.direction & UISwipeGestureRecognizerDirectionRight && oh <= ch) {
        [self previousViewController];
    }

    if (swipeGesture.direction & UISwipeGestureRecognizerDirectionLeft  && oh <= ch) {
        [self nextViewController];
    }
    if (swipeGesture.direction & UISwipeGestureRecognizerDirectionUp) {
        [self openPopupViewController];
    }
    if (swipeGesture.direction & UISwipeGestureRecognizerDirectionDown) {
        [self closePopupViewController];
    }

}

//上一个视图控制器
- (void)previousViewController {
    if (self.selectedIndex > 0) {
        [self.impactFeedback impactOccurred];
        [self setSelectedIndex:--(self.selectedIndex)];
    }
}

//下一个视图控制器
- (void)nextViewController {
    if (self.selectedIndex < self.childViewControllers.count-1) {
        [self.impactFeedback impactOccurred];
        [self setSelectedIndex:++(self.selectedIndex)];
    }
}

- (void)openPopupViewController{

    [self.impactFeedback impactOccurred];
    CGRect newFrame = [UIScreen mainScreen].bounds;
    [UIView animateWithDuration:1.0 delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.visualEffectView.frame = newFrame;
        self.popupViewController.view.frame = self.visualEffectView.contentView.bounds;//newFrame;
        if ([self.popupViewController respondsToSelector:@selector(mmTabBarControllerDidOpenPopupWithBounds:)]) {
            [self.popupViewController mmTabBarControllerDidOpenPopupWithBounds:newFrame];
        }
    } completion:nil];

}
- (void)closePopupViewController{

    [self.impactFeedback impactOccurred];
    [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.visualEffectView.frame = self.popupFrame;
        self.popupViewController.view.frame = self.visualEffectView.contentView.bounds;//self.popupFrame;
        if ([self.popupViewController respondsToSelector:@selector(mmTabBarControllerDidClosePopupWithBounds:)]) {
            [self.popupViewController mmTabBarControllerDidClosePopupWithBounds:self.popupFrame];
        }
    } completion:nil];
}


- (void)addPopupViewController:(UIViewController<MMTabbarControllerPopupDelegate> *)popupViewController{
    self.popupViewController = popupViewController;
    self.popupViewController.view.frame = self.visualEffectView.bounds;
    [self.visualEffectView.contentView addSubview:self.popupViewController.view];
}

@end
