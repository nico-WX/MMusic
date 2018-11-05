//
//  PlayerViewController_02-02.m
//  TESTUI-02
//
//  Created by 🐙怪兽 on 2018/11/4.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

#import "PlayerViewController_02.h"
#import "POPBottomView.h"
#import "PlayerViewController.h"


@interface PlayerViewController_02()
@property(nonatomic, strong) PlayerViewController *playerVC;

@property(nonatomic, strong) UIVisualEffectView *visualEffectView;
@property(nonatomic, strong) POPBottomView *popView;
@end

@implementation PlayerViewController_02{
    __block CGRect bottomStatusRect;
}

@synthesize musicPlayerController = _musicPlayerController;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.playerVC = [PlayerViewController sharePlayerViewController];

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


- (void)handleGestureEvent:(UIGestureRecognizer*)gesture {
    if ([gesture isKindOfClass:UISwipeGestureRecognizer.class]) {
        UISwipeGestureRecognizer *swipe = (UISwipeGestureRecognizer*)gesture;
        if (swipe.direction & UISwipeGestureRecognizerDirectionUp) {
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
        if (swipe.direction & UISwipeGestureRecognizerDirectionDown) {
            NSLog(@"02  down  ");
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
        CGFloat spacing = 8;
        CGFloat x = 0+spacing;
        CGFloat h = 49;
        CGFloat y = CGRectGetMinY(vc.tabBar.frame)-h-spacing;
        CGFloat w = CGRectGetWidth(vc.tabBar.frame)-(spacing*2);
        self->bottomStatusRect = CGRectMake(x, y, w, h);
        [self.view setFrame:self->bottomStatusRect];


        self.popView = [[POPBottomView alloc] initWithFrame:self.view.bounds];

        [self.visualEffectView.contentView addSubview:self.popView];

        [self.view.layer setCornerRadius:10.0];
        [self.view.layer  setMasksToBounds:YES];

    });
    [super viewDidAppear:animated];
}

- (MPMusicPlayerController *)musicPlayerController{
    if (!_musicPlayerController ){
        _musicPlayerController = [MPMusicPlayerController systemMusicPlayer];
    }
    return _musicPlayerController;
}


@end
