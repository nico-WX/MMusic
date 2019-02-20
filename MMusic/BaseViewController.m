//
//  BaseViewController.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/2/17.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "BaseViewController.h"
#import "AuthManager.h"

@interface BaseViewController ()
@property(nonatomic,strong)AuthManager *authManager;
@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.authManager = [AuthManager shareManager];

    //更新Token
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(tokenDidUpdate)
                   name:tokenDidUpdatedNotification
                 object:nil];

//    NSLog(@"developerToke =%@",self.authManager.developerToken);
//    NSLog(@"userToken =%@",self.authManager.userToken);
//    NSLog(@"front = %@",self.authManager.storefront);
}

- (void)dealloc{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:tokenDidUpdatedNotification object:nil];
}
- (void)tokenDidUpdate{
    NSLog(@"handel tokenDidUpdate notification");
}
@end
