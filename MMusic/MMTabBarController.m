//
//  MMTabBarController.m
//
//  Created by 🐙怪兽 on 2018/11/8.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "MMTabBarController.h"

@interface MMTabBarController ()
@property(nonatomic, strong)UIViewController *popViewController;        //pop VC
@property(nonatomic, strong)UIVisualEffectView *visualEffectView;       //背景效果
@property(nonatomic, strong)UIImpactFeedbackGenerator *impactFeedback;  //手势反馈
@end

@implementation MMTabBarController

- (instancetype)init{
    if (self =[super init]) {
        _impactFeedback = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleHeavy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tabBar setHidden:YES];

    //初始化 popFrame
    _popFrame = ({
        CGFloat spacing = 8.0f;
        CGFloat x = spacing;
        CGFloat w = CGRectGetWidth(self.view.frame)-(spacing*2);
        CGFloat h = 55.0f;
        CGFloat y = CGRectGetMaxY(self.view.frame)-(h+spacing);

        // tabBar 隐藏
        if (NO == self.tabBar.hidden) {
            y = CGRectGetMinY(self.tabBar.frame) - (spacing+h);
        }

        //iPhone X home 指示器 偏移 34 点
        if (CGRectGetHeight([UIScreen mainScreen].bounds) >= 812) {
            y -= 34;
        }

        CGRectMake(x, y, w, h);
    });

    //模糊效果视图
    self.visualEffectView = ({
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        effectView.frame = self.popFrame;
        [effectView.layer setCornerRadius:6.0f];
        [effectView.layer setMasksToBounds:YES];
        effectView;
    });

    [self.view addSubview:self.visualEffectView];

    //安装手势
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

        //左右手势i添加到主视图中左右切换视图控制器
        [self.view addGestureRecognizer:leftSwipe];
        [self.view addGestureRecognizer:rightSwipe];
        //上下手势添加到效果视图的内容视图中, 显示和隐藏popup h视图
        [self.visualEffectView addGestureRecognizer:upSwipe];
        [self.visualEffectView addGestureRecognizer:downSwipe];
    });


    //播放状态改变时, 隐藏或显示
    [self popStateForState:MainPlayer.playbackState];
    [[NSNotificationCenter defaultCenter] addObserverForName:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self popStateForState:MainPlayer.playbackState];
    }];
}
- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
}


//处理手势
- (void)handleSwipeGesture:(UISwipeGestureRecognizer*)swipeGesture {

    //打开popupView 时, 拦截左右切换VC 手势(判断 当前popupView 高度)
    CGFloat vcH = CGRectGetHeight(self.popViewController.view.frame);
    CGFloat popH = CGRectGetHeight(self.popFrame);

    BOOL isOpen = vcH > popH;

    if (swipeGesture.direction & UISwipeGestureRecognizerDirectionRight && !isOpen) {
        [self previousViewController];
    }

    if (swipeGesture.direction & UISwipeGestureRecognizerDirectionLeft  && !isOpen) {
        [self nextViewController];
    }
    if (swipeGesture.direction & UISwipeGestureRecognizerDirectionUp && !isOpen) {
        [self poppingViewController:YES];
    }
    if (swipeGesture.direction & UISwipeGestureRecognizerDirectionDown && isOpen) {
        [self poppingViewController: NO];
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

// pop 与 popping
- (void)poppingViewController:(BOOL)popping{
    [self.impactFeedback impactOccurred];
    if (popping) {
        //打开
        CGRect newFrame = [UIScreen mainScreen].bounds;
        [UIView animateWithDuration:1.0 delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.visualEffectView.frame = newFrame;
            self.popViewController.view.frame = self.visualEffectView.contentView.bounds;//newFrame;
            if (self.popupStateDelegate && [self.popupStateDelegate respondsToSelector:@selector(mmTabBarControllerPopupState:whitFrame:)]) {
                [self.popupStateDelegate mmTabBarControllerPopupState:YES whitFrame:newFrame];
            }
        } completion:nil];

    }else{
        //关闭
        [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.visualEffectView.frame = self.popFrame;
            self.popViewController.view.frame = self.visualEffectView.contentView.bounds;//self.popupFrame;
            if (self.popupStateDelegate && [self.popupStateDelegate respondsToSelector:@selector(mmTabBarControllerPopupState:whitFrame:)]) {
                [self.popupStateDelegate mmTabBarControllerPopupState:NO whitFrame:self.popFrame];
            }
        } completion:nil];
    }
}

- (void)addPopViewController:(UIViewController *)popViewController{
    self.popViewController = popViewController;
    self.popViewController.view.frame = self.visualEffectView.bounds;
    [self.visualEffectView.contentView addSubview:self.popViewController.view];
}

//播放状态改变时, 隐藏u或显示pop 视图
- (void)popStateForState:(MPMusicPlaybackState)state{
    switch (state) {
        case MPMusicPlaybackStateStopped:
        case MPMusicPlaybackStatePaused:{
            CGRect frame = self.popFrame;
            frame.origin.y = CGRectGetMaxY([UIScreen mainScreen].bounds);
            [UIView animateWithDuration:0.5 animations:^{
                [self.visualEffectView setFrame:frame];
            }];
        }
            break;

        default:
            [UIView animateWithDuration:0.3 animations:^{
                [self.visualEffectView setFrame:self.popFrame];
            }];
            break;
    }
}


@end
