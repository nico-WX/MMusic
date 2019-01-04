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
#import "MMTabBarController.h"
#import "AuthManager.h"
#import "MMDataStack.h"

@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    [AuthManager checkAuthTokenWith:^(AuthManager *auth) {

    }];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    MMTabBarController *root = [[MMTabBarController alloc] init];
    [self.window setRootViewController:root];
    [self.window makeKeyAndVisible];

    [MMDataStack shareDataStack];
    [MainPlayer beginGeneratingPlaybackNotifications];

    return YES;
}


- (void)applicationWillTerminate:(UIApplication *)application{
    [MainPlayer endGeneratingPlaybackNotifications];
    //保存托管对象
    NSError *error = nil;
    [[MMDataStack shareDataStack].context save:&error];
    NSAssert(error, @"保存上下文错误");
}

@end
