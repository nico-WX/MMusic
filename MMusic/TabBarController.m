//
//  TabBarController.m
//
//  Created by 🐙怪兽 on 2018/11/8.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import "TabBarController.h"

//chile vc
#import "NowPlayingViewController.h"
#import "RecommendationViewController.h"
#import "SearchViewController.h"
#import "MyMusicViewController.h"
#import "ChartsViewController.h"

@interface TabBarController ()
@property(nonatomic, strong)UIViewController *popViewController;       
@property(nonatomic, strong)UIVisualEffectView *visualEffectView;       //背景效果
@property(nonatomic, strong)UIImpactFeedbackGenerator *impactFeedback;  //手势反馈
@end

@implementation TabBarController

- (void)viewDidLoad {
    [super viewDidLoad];

    //[self.tabBar setHidden:YES];
    [self.view setBackgroundColor:UIColor.whiteColor];

    _popFrame = ({
        CGFloat w = PlayerPopSize.width;
        CGFloat h = PlayerPopSize.height;
        CGFloat x = 0;
        CGFloat y = CGRectGetMinY(self.tabBar.frame) - h;
        if ([self.tabBar isHidden]) {
            y += CGRectGetHeight(self.tabBar.frame);

            // 无Home 键 Y偏移 -34点
            BOOL isiPhoneX = CGRectGetHeight([UIScreen mainScreen].bounds) > 812;
            if (isiPhoneX) {
                y -= 34;
            }
        }
        CGRectMake(x, y, w, h);
    });

    // 添加效果视图
    [self.view addSubview:self.visualEffectView];
    [self addPopViewController:[NowPlayingViewController sharePlayerViewController]];

    //安装手势
    [self setupGesture];
    //添加子视图控制器
    [self setupChildViewController];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];

    UIView *transition = [self.view.subviews objectAtIndex:0];
    CGRect frame = transition.frame;
    frame.size.height -= self.popFrame.size.height;
    [transition setFrame:frame];
}

#pragma  mark - help

- (void)setupGesture{
    UISwipeGestureRecognizer *rightSwipe = [UISwipeGestureRecognizer new];
    UISwipeGestureRecognizer *leftSwipe  = [UISwipeGestureRecognizer new];
    UISwipeGestureRecognizer *upSwipe    = [UISwipeGestureRecognizer new];
    UISwipeGestureRecognizer *downSwipe  = [UISwipeGestureRecognizer new];

    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [leftSwipe  setDirection:UISwipeGestureRecognizerDirectionLeft];
    [upSwipe    setDirection:UISwipeGestureRecognizerDirectionUp];
    [downSwipe  setDirection:UISwipeGestureRecognizerDirectionDown];

    [leftSwipe  addTarget:self action:@selector(handleSwipeGesture:)];
    [rightSwipe addTarget:self action:@selector(handleSwipeGesture:)];
    [upSwipe    addTarget:self action:@selector(handleSwipeGesture:)];
    [downSwipe  addTarget:self action:@selector(handleSwipeGesture:)];

    //左右手势添加到主视图中左右切换视图控制器
    [self.view addGestureRecognizer:leftSwipe];
    [self.view addGestureRecognizer:rightSwipe];

    //上下手势添加到效果视图的内容视图中, 显示和隐藏popup 视图
    [self.visualEffectView addGestureRecognizer:upSwipe];
    [self.visualEffectView addGestureRecognizer:downSwipe];
}

- (void)setupChildViewController{

    //今日推荐
    RecommendationViewController *todayVC = [[RecommendationViewController alloc] init];
    [todayVC setTitle:@"今日推荐"];
    UINavigationController *todayNav = [[UINavigationController alloc] initWithRootViewController:todayVC];

    //排行榜
    ChartsViewController *chartsViewController = [[ChartsViewController alloc] init];
    [chartsViewController setTitle:@"排行榜"];
    UINavigationController *chartsNav = [[UINavigationController alloc] initWithRootViewController:chartsViewController];

    //搜索
    SearchViewController *searchViewController = [[SearchViewController alloc] init];
    [searchViewController setTitle:@"搜索"];
    UINavigationController *searchNav = [[UINavigationController alloc] initWithRootViewController:searchViewController];

    //我的音乐
    MyMusicViewController  *myMusicVC =[[MyMusicViewController alloc] init];
    UINavigationController *myMusicNav = [[UINavigationController alloc] initWithRootViewController:myMusicVC];
    [myMusicVC setTitle:@"我的音乐"];

    //添加控制器
    [self addChildViewController:todayNav];
    [self addChildViewController:chartsNav];
    [self addChildViewController:searchNav];
    [self addChildViewController:myMusicNav];

    //设置item 图标
    [todayVC.tabBarItem setImage:[UIImage imageNamed:@"recom"]];
    [chartsNav.tabBarItem setImage:[UIImage imageNamed:@"Chart"]];
    UITabBarItem *searchItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemSearch tag:2];
    [searchNav setTabBarItem:searchItem];
    [myMusicNav.tabBarItem setImage:[UIImage imageNamed:@"Library"]];
}

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

    //当前状态 frame
    CGRect newFrame = popping ? [UIScreen mainScreen].bounds : _popFrame;

    [UIView animateWithDuration:0.8
                          delay:0.0
         usingSpringWithDamping:0.6
          initialSpringVelocity:0.1
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
        [self.visualEffectView setFrame:newFrame];
    } completion:nil];
}

- (void)addPopViewController:(UIViewController *)popViewController{

    self.popViewController = popViewController;
    [self.visualEffectView.contentView addSubview:popViewController.view];
    popViewController.view.frame = self.visualEffectView.contentView.bounds;
    [popViewController didMoveToParentViewController:self];
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

- (UIImpactFeedbackGenerator *)impactFeedback{
    if (!_impactFeedback) {
        _impactFeedback = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleHeavy];
    }
    return _impactFeedback;
}

@end
