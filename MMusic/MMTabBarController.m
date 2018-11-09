//
//  MMTabBarController.m

//
//  Created by 🐙怪兽 on 2018/11/8.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import "MMTabBarController.h"


@interface MMTabBarController ()
@property(nonatomic, strong)UIViewController *popupViewController;
@property(nonatomic, strong)UIViewController *openViewController;
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (CGRectGetHeight(self.tabBar.frame) > 49) {
        self.popupFrame = CGRectOffset(self.popupFrame, 0, -34); //34 为home indicator 
        [self.visualEffectView setFrame:self.popupFrame];
    }
}

- (void)handleSwipeGesture:(UISwipeGestureRecognizer*)swipeGesture {


    if (swipeGesture.direction & UISwipeGestureRecognizerDirectionRight) {
        [self previousViewController];
    }

    if (swipeGesture.direction & UISwipeGestureRecognizerDirectionLeft) {
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
        self.popupViewController.view.alpha = 0.0;
        self.openViewController.view.alpha  = 1.0;
    } completion:^(BOOL finished) {

    }];

}
- (void)closePopupViewController{

    [self.impactFeedback impactOccurred];
    [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.visualEffectView.frame = self.popupFrame;
        self.openViewController.view.alpha  = 0.0;
        self.popupViewController.view.alpha = 1.0;
    } completion:^(BOOL finished) {

    }];

}


- (void)addOpenViewController:(UIViewController *)openViewController{
    self.openViewController = openViewController;
    self.openViewController.view.alpha = 0;
    [self.visualEffectView.contentView addSubview:self.openViewController.view];
}
- (void)addPopupViewController:(UIViewController *)popupViewController{
    self.popupViewController = popupViewController;
    self.popupViewController.view.frame = self.visualEffectView.bounds;
    [self.visualEffectView.contentView addSubview:self.popupViewController.view];
}

@end
