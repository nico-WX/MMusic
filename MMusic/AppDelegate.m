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
@property(nonatomic, strong) NSManagedObjectContext *moc;
@property(nonatomic, strong) AuthManager *authManager;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    TabBarController *root = [[TabBarController alloc] init];
    [self.window setRootViewController:root];
    [self.window makeKeyAndVisible];

    //初始化
    self.authManager = [AuthManager shareManager];

    self.moc = [CoreDataStack shareDataStack].context;
    [MainPlayer beginGeneratingPlaybackNotifications];

    return YES;
}


- (void)applicationWillTerminate:(UIApplication *)application{
    [MainPlayer endGeneratingPlaybackNotifications];
    //保存托管对象
    NSError *error = nil;
    [self.moc save:&error];
    NSAssert(error, @"保存上下文错误");
}

@end
