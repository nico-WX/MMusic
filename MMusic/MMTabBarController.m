//
//  MMTabBarController.m
//
//  Created by 🐙怪兽 on 2018/11/8.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <Masonry.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MMTabBarController.h"

//vc
#import "NowPlayingViewController.h"
#import "RecommendationViewController.h"
#import "MMSearchMainViewController.h"
#import "MyMusicViewController.h"
#import "ChartsViewController.h"

@interface MMTabBarController ()
@property(nonatomic, strong)UIViewController *popViewController;        //强引用
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

    //[self.tabBar setHidden:YES];
    //初始化 popFrame
    _popFrame = ({
        UIEdgeInsets padding = UIEdgeInsetsMake(0, 8, 6, 8);
        CGFloat x = padding.left;
        CGFloat w = CGRectGetWidth(self.view.frame)-(padding.left*2);
        CGFloat h = 55.0f;
        CGFloat y = CGRectGetMaxY(self.view.frame)-(h+padding.bottom);

        // tabBar 没有隐藏
        if (NO == self.tabBar.hidden) {
            y = CGRectGetMinY(self.tabBar.frame) - (padding.bottom+h);
        }

        //iPhone X home 指示器 偏移 34 点
        if (CGRectGetHeight([UIScreen mainScreen].bounds) >= 812) {
            y -= 34;
        }

        CGRectMake(x, y, w, h);
    });

    // 添加效果视图
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
//    [self popStateForState:MainPlayer.playbackState];
//    [[NSNotificationCenter defaultCenter] addObserverForName:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
//        [self popStateForState:MainPlayer.playbackState];
//    }];


    //添加子视图控制器
    ({
        //播放器
        [self addPopViewController:[NowPlayingViewController sharePlayerViewController]];

        //first : 今日推荐
        RecommendationViewController *todayCVC = [[RecommendationViewController alloc] init];
        [todayCVC setTitle:@"今日推荐"];
        UINavigationController *todayNav = [[UINavigationController alloc] initWithRootViewController:todayCVC];

        //排行榜
        ChartsViewController *chartsViewController = [[ChartsViewController alloc] init];
        [chartsViewController setTitle:@"排行榜"];
        UINavigationController *chartsNav = [[UINavigationController alloc] initWithRootViewController:chartsViewController];

        //secon 搜索
        MMSearchMainViewController *searchViewController = [[MMSearchMainViewController alloc] init];
        [searchViewController setTitle:@"搜索"];
        UINavigationController *searchNav = [[UINavigationController alloc] initWithRootViewController:searchViewController];
        UITabBarItem *searchItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemSearch tag:2];
        [searchNav setTabBarItem:searchItem];

        //three 我的音乐
        MyMusicViewController  *mmusicVC =[[MyMusicViewController alloc] init];
        UINavigationController *mmusicNavCtr = [[UINavigationController alloc] initWithRootViewController:mmusicVC];
        [mmusicVC setTitle:@"我的音乐"];

        //添加控制器
        [self addChildViewController:todayNav];
        [self addChildViewController:chartsNav];
        [self addChildViewController:searchNav];
        [self addChildViewController:mmusicNavCtr];

        //设置item 图标
        [todayCVC.tabBarItem setImage:[UIImage imageNamed:@"recom"]];
        [chartsNav.tabBarItem setImage:[UIImage imageNamed:@"Chart"]];
        [mmusicNavCtr.tabBarItem setImage:[UIImage imageNamed:@"Library"]];
    });

}

#pragma  mark - 辅助方法

//处理手势
- (void)handleSwipeGesture:(UISwipeGestureRecognizer*)swipeGesture {

    //打开popupView 时, 拦截左右切换VC 手势(判断 当前popupView 高度)
    CGFloat h = CGRectGetHeight(self.visualEffectView.contentView.frame);

    // 当前是否已经打开, 打开时, 只接受向下滑动手势;
    BOOL isOpen = h > CGRectGetHeight(self.popFrame);

    //向右滑动
    if (swipeGesture.direction & UISwipeGestureRecognizerDirectionRight && !isOpen) {
        [self previousViewController];
    }

    //向左滑动
    if (swipeGesture.direction & UISwipeGestureRecognizerDirectionLeft  && !isOpen) {
        [self nextViewController];
    }

    //向上滑动
    if (swipeGesture.direction & UISwipeGestureRecognizerDirectionUp && !isOpen) {
        [self poppingViewController:YES];
    }

    //向下滑动;
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

    CGRect newFrame ;
    if (popping) {
        newFrame = [[UIScreen mainScreen] bounds];
    }else{
        newFrame = self.popFrame;
    }

    [UIView animateWithDuration:0.8 delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.visualEffectView setFrame:newFrame];
    } completion:nil];
}

- (void)addPopViewController:(UIViewController *)popViewController{

    self.popViewController = popViewController; // 持有该视图控制器
    [self.visualEffectView.contentView addSubview:popViewController.view];

    //布局
    UIView *superView = self.visualEffectView.contentView;
    [popViewController.view mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(superView);
    }];

}

//播放状态改变时, 隐藏u或显示pop 视图
- (void)popStateForState:(MPMusicPlaybackState)state{

    // 打开状态下, 暂停或者停止不隐藏
    if (CGRectGetHeight(self.visualEffectView.contentView.bounds) < 100) {
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
}

#pragma mark - getter

- (UIVisualEffectView *)visualEffectView{
    if (!_visualEffectView) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        _visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        [_visualEffectView.layer setCornerRadius:6.0f];
        [_visualEffectView.layer setMasksToBounds:YES];
        [_visualEffectView setFrame:_popFrame];
    }
    return _visualEffectView;
}

@end
