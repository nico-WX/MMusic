//
//  AppDelegate.m
//  MMusic
//
//  Created by Magician on 2017/11/6.
//  Copyright © 2017年 com.😈. All rights reserved.
//
#import <MBProgressHUD.h>
#import <StoreKit/StoreKit.h>

#import "AppDelegate.h"

//Controller
#import "MyMusicViewController.h"
#import "TodayCollectionViewController.h"
#import "ChartsPageViewController.h"
#import "BrowseViewController.h"
#import "SearchViewController.h"

#import "AuthorizationManager.h"

@interface AppDelegate ()<SKCloudServiceSetupViewControllerDelegate>
@property(nonatomic, strong) AuthorizationManager *auth;
@property(nonatomic, strong) SKCloudServiceSetupViewController *subscriptionVC;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    //实例化主窗口
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    //定时锁屏
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];



    Log(@"path =%@",DB_PATH);


    //检查授权
    [self checkAuthorization];

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
    BrowseViewController *browseVC = BrowseViewController.new;
    browseVC.title = @"浏览";
    UINavigationController *browseNav = [[UINavigationController alloc] initWithRootViewController:browseVC];

    //music
    UIViewController *musicVC = UIViewController.new;
    musicVC.title = @"音乐库";
    UINavigationController *musicNav = [[UINavigationController alloc] initWithRootViewController:musicVC];

    //添加控制器
    [barCtr addChildViewController:todayNavCtr];
    [barCtr addChildViewController:chartNav];
    [barCtr addChildViewController:browseNav];
    [barCtr addChildViewController:musicNav];
    [barCtr addChildViewController:mmusicNavCtr];

    //设置item 图标
    [todayNavCtr.tabBarItem setImage:[UIImage imageNamed:@"今日推荐"]];
    [chartNav.tabBarItem setImage:[UIImage imageNamed:@"排行榜"]];
    [browseNav.tabBarItem setImage:[UIImage imageNamed:@"浏览"]];
    [mmusicNavCtr.tabBarItem setImage:[UIImage imageNamed:@"我的"]];
    [musicNav.tabBarItem setImage:[UIImage imageNamed:@"music"]];

    //[barCtr setSelectedIndex:2];

    [self.window setRootViewController:barCtr];
    [self.window makeKeyAndVisible];    //显示
    return YES;
}

//检查授权
-(void)checkAuthorization{
    //验证用户授权状态
    [SKCloudServiceController requestAuthorization:^(SKCloudServiceAuthorizationStatus status) {
        switch (status) {
                //授权获取音乐资料库
            case SKCloudServiceAuthorizationStatusAuthorized:{
                //检查用户订阅状态
                [[SKCloudServiceController new] requestCapabilitiesWithCompletionHandler:^(SKCloudServiceCapability capabilities, NSError * _Nullable error) {

                    if (capabilities == SKCloudServiceCapabilityNone) {
                        //没有订阅 显示订阅视图
                        [self showSubscriptionView];
                    }else{
                        //已订阅 请求基本的userToken  等
                        self.auth = [AuthorizationManager shareAuthorizationManager];
                        //Log(@"user =%@",self.auth.userToken);
                    }
                }];
            }
                break;

            case SKCloudServiceAuthorizationStatusDenied:{
                //拒绝授权
                [self showHUDTOMainWindowWithInfo:@"用户拒绝获取音乐库信息,请手动开启"];
            }
                break;
            case SKCloudServiceAuthorizationStatusRestricted:
                //重置
                break;
            case SKCloudServiceAuthorizationStatusNotDetermined:
                //未决定
                break;
        }

    }];
}


//显示信息HUD 到主窗口
-(void) showHUDTOMainWindowWithInfo:(NSString*) text{
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
        hud.label.text = text;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [hud removeFromSuperview];
        });
    });
}
//显示订阅视图
-(void) showSubscriptionView{

    self.subscriptionVC = [[SKCloudServiceSetupViewController alloc] init];
    self.subscriptionVC.delegate = self;
    //页面设置
    NSDictionary *dict = @{SKCloudServiceSetupOptionsMessageIdentifierKey:SKCloudServiceSetupMessageIdentifierJoin,
                           SKCloudServiceSetupOptionsActionKey : SKCloudServiceSetupActionSubscribe
                           };

    [self.subscriptionVC loadWithOptions:dict completionHandler:^(BOOL result, NSError * _Nullable error) {
        if (result) {
            //隐藏导航栏
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.window addSubview:self.subscriptionVC.view];
            });
        }
    }];
}

#pragma mark - SKCloudServiceSetupViewControllerDelegate
-(void)cloudServiceSetupViewControllerDidDismiss:(SKCloudServiceSetupViewController *)cloudServiceSetupViewController{
    [cloudServiceSetupViewController.view removeFromSuperview];
}

@end
