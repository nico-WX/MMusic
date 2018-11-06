//
//  PopupViewController-02.m
//
//  Created by 🐙怪兽 on 2018/11/4.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

#import "PopupViewController.h"
#import "PopupView.h"
#import "NowPlayingViewController.h"


@interface PopupViewController()
@property(nonatomic, strong) NowPlayingViewController *playerVC;

@property(nonatomic, strong) UIVisualEffectView *visualEffectView;
@property(nonatomic, strong) PopupView *popView;
@end

@implementation PopupViewController{
    //原始位置
    __block CGRect bottomStatusRect;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    //直接替换为
    {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        self.visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        self.view = self.visualEffectView;
    }

    //安装手势识别器
    {
        UISwipeGestureRecognizer *upSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleGestureEvent:)];
        [upSwipe setDirection:UISwipeGestureRecognizerDirectionUp];
        [self.visualEffectView addGestureRecognizer:upSwipe];

        UISwipeGestureRecognizer *downSwip = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleGestureEvent:)];
        [downSwip setDirection:UISwipeGestureRecognizerDirectionDown];
        [self.visualEffectView addGestureRecognizer:downSwip];
    }

}

// 手势处理
- (void)handleGestureEvent:(UIGestureRecognizer*)gesture {
    if ([gesture isKindOfClass:UISwipeGestureRecognizer.class]) {
        UISwipeGestureRecognizer *swipe = (UISwipeGestureRecognizer*)gesture;
        if (swipe.direction & UISwipeGestureRecognizerDirectionUp && self.popView.alpha != 0 ) {
            CGRect newRect = CGRectMake(0, 0, 414, 736);
            [self.playerVC.view setFrame:newRect];
            [self.playerVC.view setAlpha:0];
            [self.visualEffectView.contentView addSubview:self.playerVC.view];

            [UIView animateWithDuration:0.6 animations:^{
                [self.popView setAlpha:0];
                [self.view setFrame:newRect];
                [self.playerVC.view setAlpha:1];
            }];
        }
        if (swipe.direction & UISwipeGestureRecognizerDirectionDown && self.popView.alpha == 0) {
            [UIView animateWithDuration:0.6 animations:^{
                [self.popView setAlpha:1];
                [self.playerVC.view setAlpha:0];
                [self.visualEffectView setFrame:self->bottomStatusRect];
            }completion:^(BOOL finished) {
                [self.playerVC.view removeFromSuperview];
            } ];
        }
    }
}
- (void)viewDidAppear:(BOOL)animated{

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        //延后设置 frame
        UITabBarController *vc = (UITabBarController*)[[UIApplication sharedApplication].keyWindow rootViewController];
        CGFloat spacing = 6;
        CGFloat x = 0+spacing;
        CGFloat h = 49;
        CGFloat y = CGRectGetMinY(vc.tabBar.frame)-h-spacing;
        CGFloat w = CGRectGetWidth(vc.tabBar.frame)-(spacing*2);
        self->bottomStatusRect = CGRectMake(x, y, w, h);
        [self.view setFrame:self->bottomStatusRect];

        self.popView = [[PopupView alloc] initWithFrame:self.view.bounds];

        [self.visualEffectView.contentView addSubview:self.popView];


        [self.view.layer setCornerRadius:8.0];
        [self.view.layer  setMasksToBounds:YES];

        //边框线
        self.view.layer.borderWidth = 0.5;
        self.view.layer.borderColor = [UIColor colorWithWhite:0.6 alpha:0.5].CGColor;

    });
    
    [super viewDidAppear:animated];
}

- (NowPlayingViewController *)playerVC {
    return [NowPlayingViewController sharePlayerViewController];
}

@end
