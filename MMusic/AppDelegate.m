//
//  AppDelegate.m
//  MMusic
//
//  Created by Magician on 2017/11/6.
//  Copyright © 2017年 com.😈. All rights reserved.
//
#import <MBProgressHUD.h>
#import <StoreKit/StoreKit.h>
#import <MediaPlayer/MediaPlayer.h>

#import "AppDelegate.h"

//Controller
#import "MMTabBarController.h"

#import "RecommendationViewController.h"
#import "MMSearchMainViewController.h"
#import "MyMusicViewController.h"
#import "NowPlayingViewController.h"

#import "AuthManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.


    //主窗口
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];

    //定时锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];


    //tabBar
    MMTabBarController *rootVC = [[MMTabBarController alloc] init];
    [self.window setRootViewController:rootVC];

    //悬浮窗口添加
    [rootVC addPopViewController:[NowPlayingViewController sharePlayerViewController]];
    //popping 状态
    //rootVC.popupStateDelegate = [NowPlayingViewController sharePlayerViewController];


    MyMusicViewController  *mmusicVC =[[MyMusicViewController alloc] init];
    UINavigationController *mmusicNavCtr = [[UINavigationController alloc] initWithRootViewController:mmusicVC];
    [mmusicVC setTitle:@"我的音乐"];

    //今日推荐
    RecommendationViewController *todayCVC = [[RecommendationViewController alloc] init];
    [todayCVC setTitle:@"今日推荐"];
    UINavigationController *todayNav = [[UINavigationController alloc] initWithRootViewController:todayCVC];

    //排行榜
    MMSearchMainViewController *chartVC = [[MMSearchMainViewController alloc] init];
    [chartVC setTitle:@"排行榜"];
    UINavigationController *chartNav = [[UINavigationController alloc] initWithRootViewController:chartVC];


    //添加控制器
    [rootVC addChildViewController:todayNav];
    [rootVC addChildViewController:chartNav];

    [rootVC addChildViewController:mmusicNavCtr];

    //设置item 图标
    [todayCVC.tabBarItem setImage:[UIImage imageNamed:@"recom"]];
    [chartNav.tabBarItem setImage:[UIImage imageNamed:@"Chart"]];
    [mmusicNavCtr.tabBarItem setImage:[UIImage imageNamed:@"Library"]];

    [MainPlayer beginGeneratingPlaybackNotifications];

    [self.window makeKeyAndVisible];    //显示
    return YES;
}


- (void)applicationWillTerminate:(UIApplication *)application{
    [MainPlayer endGeneratingPlaybackNotifications];
}

@end
