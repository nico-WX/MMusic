//
//  BaseViewController.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/2/17.
//  Copyright © 2019 com.😈. All rights reserved.
//
#import <StoreKit/StoreKit.h>
#import "BaseViewController.h"
#import "AuthManager.h"

@interface BaseViewController ()<SKCloudServiceSetupViewControllerDelegate>
@property(nonatomic,strong)AuthManager *authManager;
@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.authManager = [AuthManager shareManager];

    // 消息处理 auth 授权刷新数据  cloudServiceDidUpdate 显示订阅视图??
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(handleAuthorizationManagerDidUpdateNotification)
                   name:authorizationDidUpdateNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(handleAuthorizationManagerDidUpdateNotification)
                   name:cloudServiceDidUpdateNotification
                 object:nil];
    [center addObserver:self
               selector:@selector(handleAuthorizationManagerDidUpdateNotification)
                   name:UIApplicationWillEnterForegroundNotification
                 object:nil];

    
    NSLog(@"developerToke =%@",self.authManager.developerToken);
    NSLog(@"userToken =%@",self.authManager.userToken);
    NSLog(@"front = %@",self.authManager.storefront);
}

//授权改变, 处理
- (void)handleAuthorizationManagerDidUpdateNotification{
    //1. 判断授权,并处理
    //2. 已授权, 判断订阅情况
    if (SKCloudServiceController.authorizationStatus == SKCloudServiceAuthorizationStatusDenied || MPMediaLibrary.authorizationStatus == MPMediaLibraryAuthorizationStatusDenied) {
        //未授权 ?  是否需要在这里请求授权> 还是在AuthManager 里面??

    }else{
        //已授权 -- > 查看订阅状态
        [SKCloudServiceController.new requestCapabilitiesWithCompletionHandler:^(SKCloudServiceCapability capabilities, NSError * _Nullable error) {

            if (capabilities == SKCloudServiceCapabilityNone) {
                [self showSubscriptionView];
            }else{
//                if (self.authorizationManagerDidUpdateHandle) {
//                    mainDispatch(^{
//                        self.authorizationManagerDidUpdateHandle();
//                    });
//                }
            }
//
//            if (capabilities & SKCloudServiceCapabilityMusicCatalogPlayback) {
//            }
//            if (capabilities & SKCloudServiceCapabilityAddToCloudMusicLibrary) {
//            }
//            if (capabilities & SKCloudServiceCapabilityMusicCatalogSubscriptionEligible) {
//            }
        }];
    }
}
- (void)dealloc{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:authorizationDidUpdateNotification object:nil];
    [center removeObserver:self name:cloudServiceDidUpdateNotification object:nil];
    [center removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)showSubscriptionView{
    SKCloudServiceSetupViewController *vc = [[SKCloudServiceSetupViewController alloc] init];
    vc.delegate = self;
    //页面配置
    NSDictionary *infoDict = @{SKCloudServiceSetupOptionsMessageIdentifierKey:SKCloudServiceSetupMessageIdentifierJoin,
                               SKCloudServiceSetupOptionsActionKey : SKCloudServiceSetupActionSubscribe
                               };
    [vc loadWithOptions:infoDict completionHandler:^(BOOL result, NSError * _Nullable error) {
        if (result) {
            [self presentViewController:vc animated:YES completion:nil];
        }else{
        }
    }];
}
- (void)cloudServiceSetupViewControllerDidDismiss:(SKCloudServiceSetupViewController *)cloudServiceSetupViewController{
    NSLog(@"dismiss");
}

@end
