//
//  AppDelegate.m
//  MMusic
//
//  Created by Magician on 2017/11/6.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "AppDelegate.h"

//Controller
#import "TabBarController.h"
#import "AuthManager.h"
#import "CoreDataStack.h"

@interface AppDelegate ()
@end

@implementation AppDelegate

//-(BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
//
//    return YES;
//}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.


//    //授权检查
//    [AuthManager checkAuthTokenWith:^(AuthManager *auth) {
//
//    }];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    TabBarController *root = [[TabBarController alloc] init];
    [self.window setRootViewController:root];
    [self.window makeKeyAndVisible];

    [CoreDataStack shareDataStack];
    [MainPlayer beginGeneratingPlaybackNotifications];

    return YES;
}


- (void)applicationWillTerminate:(UIApplication *)application{
    [MainPlayer endGeneratingPlaybackNotifications];
    //保存托管对象
    NSError *error = nil;
    [[CoreDataStack shareDataStack].context save:&error];
    NSAssert(error, @"保存上下文错误");
}

@end
