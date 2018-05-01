//
//  AppDelegate.m
//  MMusic
//
//  Created by Magician on 2017/11/6.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import "AppDelegate.h"

//Controller
#import "MyMusicViewController.h"
#import "TodayCollectionViewController.h"
#import "ChartsPageViewController.h"
#import "BrowseViewController.h"
#import "SearchViewController.h"

#import "AuthorizationManager.h"

@interface AppDelegate ()
@property(nonatomic, strong) AuthorizationManager *auth;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];

    [SKCloudServiceController requestAuthorization:^(SKCloudServiceAuthorizationStatus status) {
        if (status == SKCloudServiceAuthorizationStatusAuthorized) {
            self.auth = [AuthorizationManager shareAuthorizationManager];
        }

        SKCloudServiceController *csStr = [SKCloudServiceController new];
        [csStr requestCapabilitiesWithCompletionHandler:^(SKCloudServiceCapability capabilities, NSError * _Nullable error) {
            switch (capabilities) {
                case SKCloudServiceCapabilityNone:
                    break;
                case SKCloudServiceCapabilityMusicCatalogPlayback:
                    break;
                case SKCloudServiceCapabilityAddToCloudMusicLibrary:
                    break;
                case SKCloudServiceCapabilityMusicCatalogSubscriptionEligible:
                    break;
            }
        }];

    }];

    //实例化主窗口
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];


    //tabBar
    UITabBarController *barCtr = [[UITabBarController alloc] init];

    //我的音乐
    MyMusicViewController  *mmusicVC =[[MyMusicViewController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController *mmusicNavCtr = [[UINavigationController alloc] initWithRootViewController:mmusicVC];
    [mmusicVC setTitle:@"我的音乐"];

    //今日推荐
    TodayCollectionViewController *todayCVC = [[TodayCollectionViewController alloc] init];
    [todayCVC setTitle:@"今日推荐"];
    UINavigationController *todayNavCtr = [[UINavigationController alloc] initWithRootViewController:todayCVC];

    //排行榜
    ChartsPageViewController *chartVC = [[ChartsPageViewController alloc] init];
    [chartVC setTitle:@"排行榜"];
    UINavigationController *chartNav = [[UINavigationController alloc] initWithRootViewController:chartVC];

    //搜索
    //SearchViewController *searchVC = [[SearchViewController alloc] init];
    //searchVC.title = @"搜索";
    BrowseViewController *borseVC = BrowseViewController.new;
    borseVC.title = @"浏览";
    UINavigationController *searchNav = [[UINavigationController alloc] initWithRootViewController:borseVC];


    [barCtr addChildViewController:todayNavCtr];
    [barCtr addChildViewController:chartNav];
    [barCtr addChildViewController:searchNav];
    [barCtr addChildViewController:mmusicNavCtr];

    [barCtr setSelectedIndex:2];

    [self.window setRootViewController:barCtr];
    [self.window makeKeyAndVisible];    //显示
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
