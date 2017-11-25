//
//  AppDelegate.m
//  MMusic
//
//  Created by Magician on 2017/11/6.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import <StoreKit/StoreKit.h>

#import "AppDelegate.h"
#import "BrowseCollectionViewController.h"
#import "BrowseNavigationController.h"
#import "BrowseViewController.h"
#import "MyMusicViewController.h"
#import "AuthorizationManager.h"

#import "RequestFactory.h"
#import "PersonalizedRequestFactory.h"

extern NSString *userTokenUserDefaultsKey;
@interface AppDelegate ()
@property(nonatomic, strong) AuthorizationManager *auth;
@property(nonatomic, strong) SKCloudServiceController *controller;
@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //实例化主窗口
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.auth = [AuthorizationManager shareAuthorizationManager];

    {
    RequestFactory *requestFac = [[RequestFactory alloc] init];
    PersonalizedRequestFactory *personal = [[PersonalizedRequestFactory alloc] init];
//    NSArray *arr = @[@"203709340",@"201281527"];
//    NSURLRequest *request = [requestFac createRequestWithType:RequestMultipleSongType resourceIds:arr];
//    NSURLRequest *request = [requestFac createRequestWithType:RequestGenresType resourceIds:@[@"35"]];
//    NSURLRequest *request = [requestFac createSearchHintsWithTerm:@"星"];
    NSURLRequest *request = [personal createRequestWithType:PersonalizedMultipleRecommendationType resourceIds:@[@"6",@"5",@"2"]];
    Log(@"%@",request.URL.absoluteString);
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            Log(@"%@",dict);
        }else if(error){
            Log(@"Error:%@",error);
        }

    }] resume];
    }

    //我的音乐
    MyMusicViewController   *musicCtr = [[MyMusicViewController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController  *navCtr = [[UINavigationController alloc] initWithRootViewController:musicCtr];
    UITabBarController      *barCtr = [[UITabBarController alloc] init];
    [barCtr addChildViewController:navCtr];

    //浏览
    BrowseViewController *bVC = [[BrowseViewController alloc] init];
    [bVC setTitle:@"浏览"];
    BrowseNavigationController      *bnavCtr = [[BrowseNavigationController alloc] initWithRootViewController:bVC];
    [barCtr addChildViewController:bnavCtr];
    [barCtr setSelectedIndex:1];
    //添加并显示(不隐藏)
    [self.window setRootViewController:barCtr];
    [self.window makeKeyAndVisible];
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
