//
//  MMTabBarController.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/6.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

#import "MMTabBarController.h"
#import "NowPlayingViewController.h"
#import "PopupViewController.h"

#import "Song.h"
#import "Artwork.h"

@interface MMTabBarController ()
@property(nonatomic, strong)NowPlayingViewController *nowPlayingViewontroller;
@property(nonatomic, strong)PopupViewController *popupViewController;

@property(nonatomic, strong)UIVisualEffectView *visualEffectView;

@property(nonatomic, assign)CGRect popupFrame;
@end

@implementation MMTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];



    //popup视图位置
    self.popupFrame = ({
        CGFloat spacing = 6;
        CGFloat x = 0+spacing;
        CGFloat h = 49;
        CGFloat y = CGRectGetMinY(self.tabBar.frame)-(h+spacing);
        CGFloat w = CGRectGetWidth(self.tabBar.frame)-(spacing*2);
        CGRectMake(x, y, w, h);
    });



    // 模糊 效果视图
    self.visualEffectView = ({
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *veView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        [veView setFrame:self.popupFrame];

        //layer set
        [veView.layer setCornerRadius:8.0];
        [veView.layer  setMasksToBounds:YES];
        [veView.layer setBorderWidth:0.5];
        [veView.layer setBorderColor:[UIColor colorWithWhite:0.6 alpha:0.5].CGColor];

        veView;
    });

    // content
    self.nowPlayingViewontroller = [NowPlayingViewController sharePlayerViewController];
    self.popupViewController = ({
        PopupViewController *popupVC = [[PopupViewController alloc] init];
        [popupVC.view setFrame:self.visualEffectView.bounds];
        popupVC;
    });

    // add view
    [self.view addSubview:self.visualEffectView];
    [self.visualEffectView.contentView addSubview:self.popupViewController.view];

    //绑定手势
    ({
        UISwipeGestureRecognizer *upSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleGestureEvent:)];
        [upSwipe setDirection:UISwipeGestureRecognizerDirectionUp];
        [self.visualEffectView addGestureRecognizer:upSwipe];

        UISwipeGestureRecognizer *downSwip = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleGestureEvent:)];
        [downSwip setDirection:UISwipeGestureRecognizerDirectionDown];
        [self.visualEffectView addGestureRecognizer:downSwip];
    });


    NSLog(@"self.view =%@",NSStringFromCGRect(self.view.frame));
    NSLog(@"popupFrame =%@",NSStringFromCGRect(self.popupFrame));
    NSLog(@"popviewframe =%@",NSStringFromCGRect(self.popupViewController.view.frame));
}


- (void)handleGestureEvent:(UISwipeGestureRecognizer*)gesture {

    //向上
    if (gesture.direction & UISwipeGestureRecognizerDirectionUp && self.popupViewController.view.alpha != 0 ) {
        CGRect newRect = CGRectMake(0, 0, 414, 736);
        [self.nowPlayingViewontroller.view setFrame:newRect];
        [self.visualEffectView.contentView addSubview:self.nowPlayingViewontroller.view];
        [self.popupViewController.view setAlpha:0];
        [UIView animateWithDuration:0.6 animations:^{
            [self.visualEffectView setFrame:newRect];
            [self.nowPlayingViewontroller.view setAlpha:1];
        }];
    }
    //向下
    if (gesture.direction & UISwipeGestureRecognizerDirectionDown && self.popupViewController.view.alpha == 0) {

        [UIView animateWithDuration:0.6 animations:^{
            [self.visualEffectView setFrame:self.popupFrame];
            [self.nowPlayingViewontroller.view setAlpha:0];
            [self.popupViewController.view setAlpha:1];
        }completion:^(BOOL finished) {
            //[self.popupViewController.view setNeedsDisplay];
            //[self.nowPlayingViewontroller.view removeFromSuperview];
        } ];
    }
}

@end
