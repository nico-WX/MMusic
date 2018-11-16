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
#import "ChartsMainViewController.h"
#import "MyMusicViewController.h"
#import "BrowseViewController.h"
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
    [rootVC addPopupViewController:[NowPlayingViewController sharePlayerViewController]];


    UIDevice *device = [UIDevice currentDevice];
    /**
     @property(nonatomic,readonly,strong) NSString    *name;              // e.g. "My iPhone"
     @property(nonatomic,readonly,strong) NSString    *model;             // e.g. @"iPhone", @"iPod touch"
     @property(nonatomic,readonly,strong) NSString    *localizedModel;    // localized version of model
     @property(nonatomic,readonly,strong) NSString    *systemName;        // e.g. @"iOS"
     @property(nonatomic,readonly,strong) NSString    *systemVersion;     // e.g. @"4.0"
     */

    NSLog(@"name =%@",device.name);
    NSLog(@"model =%@",device.model);
    NSLog(@"localized model =%@",device.localizedModel);
    NSLog(@"systemNAme =%@",device.systemName);
    NSLog(@"systemVersion =%@",device.systemVersion);
    
    
    MyMusicViewController  *mmusicVC =[[MyMusicViewController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController *mmusicNavCtr = [[UINavigationController alloc] initWithRootViewController:mmusicVC];
    [mmusicVC setTitle:@"我的音乐"];

    //今日推荐
    RecommendationViewController *todayCVC = [[RecommendationViewController alloc] init];
    [todayCVC setTitle:@"今日推荐"];

    //排行榜
    ChartsMainViewController *chartVC = [[ChartsMainViewController alloc] init];
    [chartVC setTitle:@"排行榜"];
    UINavigationController *chartNav = [[UINavigationController alloc] initWithRootViewController:chartVC];

    //浏览
    BrowseViewController *browseVC = BrowseViewController.new;
    [browseVC setTitle:@"浏览"];
    UINavigationController *browseNav = [[UINavigationController alloc] initWithRootViewController:browseVC];

    //添加控制器
    [rootVC addChildViewController:todayCVC];
    [rootVC addChildViewController:chartNav];
    [rootVC addChildViewController:browseNav];
    [rootVC addChildViewController:mmusicNavCtr];

    //设置item 图标
    [todayCVC.tabBarItem setImage:[UIImage imageNamed:@"recom"]];
    [chartNav.tabBarItem setImage:[UIImage imageNamed:@"Chart"]];
    [browseNav.tabBarItem setImage:[UIImage imageNamed:@"browse"]];
    [mmusicNavCtr.tabBarItem setImage:[UIImage imageNamed:@"Library"]];

    [MainPlayer beginGeneratingPlaybackNotifications];

    [self.window makeKeyAndVisible];    //显示
    return YES;
}


- (void)applicationWillTerminate:(UIApplication *)application{
    [MainPlayer endGeneratingPlaybackNotifications];
}

@end
