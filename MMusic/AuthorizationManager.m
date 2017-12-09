//
//  AuthorizationManager.m
//  MMusic
//
//  Created by Magician on 2017/11/10.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "AuthorizationManager.h"
#import <StoreKit/StoreKit.h>

/**Token缓存Key*/
NSString *userTokenUserDefaultsKey  = @"userTokenUserDefaultsKey";
NSString *developerTokenDefaultsKey = @"developerTokenDefaultsKey";
NSString *storefrontDefaultsKey     = @"storefrontDefaultsKey";

/**开发者Token过期通知*/
NSString * const developerTokenExpireNotification  = @"developerTokenExpire";
NSString * const userAuthorizedNotification        = @"userAuthorized";

@interface AuthorizationManager()
@end

static AuthorizationManager *_instance;
@implementation AuthorizationManager

# pragma mark 初始化及单例实现
-(instancetype)init{
    if (self = [super init]) {
        //开发者Token 过期消息 (UserToken不会过期) 删除旧的developerToken  并请求一个新的
        [[NSNotificationCenter defaultCenter] addObserverForName:developerTokenExpireNotification object:self queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            //移除过期DeveloperToken
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:developerTokenDefaultsKey];
            //请求新的developerToken
            [self requestDeveloperToken];
        }];
    }
    return self;
}

-(void)dealloc{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:developerTokenExpireNotification object:nil];
}

+(instancetype)shareAuthorizationManager{
    if (!_instance) {
        _instance = [[self alloc] init];
    }
    return _instance;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone{
    //防止同时访问
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_instance) {
            _instance = [super allocWithZone:zone];
        }
    });
    return _instance;
}

-(id)copyWithZone:(NSZone *)zone{
    return _instance;
}

-(id)mutableCopyWithZone:(NSZone *)zone{
    return _instance;
}

#if __has_feature(objc_arc)
//ARC
#else
//MRC
- (oneway void)release{
    //拦截释放
}
- (instancetype)retain{
    //拦截增加引用计数
    return _instance;
}
- (NSUInteger)retainCount{
    return  MAXFLOAT;
}
#endif

#pragma mark 懒加载
//检查developerToken
-(NSString *)developerToken{
    if (!_developerToken) {
        _developerToken = [[NSUserDefaults standardUserDefaults] objectForKey:developerTokenDefaultsKey];
        _developerToken = @"eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NiIsInR5cGUiOiJKV1QiLCJraWQiOiJTMkhFRlRWM0o5In0.eyJpc3MiOiJWOVc4MzdZNkFWIiwiaWF0IjoxNTExODgyNjU5LCJleHAiOjE1Mjc0MzQ2NTl9.fbtthWV4K0kUedKa55CYN3y02SsrzwZLtTPhLfqQhYtovw-b5uk7ab-3O1YKQ1TtXn68Wdtv6TOUhw164Lv1hQ";
        if (!_developerToken) {
            [self requestDeveloperToken];
        }
    }
    return _developerToken;
}
//检查userToken是否在默认设置中存在
-(NSString *)userToken{
    if (!_userToken) {
        _userToken = [[NSUserDefaults standardUserDefaults] objectForKey:userTokenUserDefaultsKey];
        if (!_userToken) {
            [self requestUserToken];
        }
    }
    return _userToken;
}
-(NSString *)storefront{
    if (!_storefront) {
        _storefront = [[NSUserDefaults standardUserDefaults] objectForKey:storefrontDefaultsKey];
        if (!_storefront) {
            [self requestStorefront];
        }
    }
    return _storefront;
}

#pragma mark 从网络请求token
/**请求开发者Token 并缓存在默认设置*/
- (void)requestDeveloperToken{
    __block NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:developerTokenDefaultsKey];
    if (!token) {
#warning DeveloperTokenURL no set!
        NSString *urlStr = @"";
        NSURL *url = [NSURL URLWithString:urlStr];
        [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

            NSHTTPURLResponse *res = (NSHTTPURLResponse*) response;
            if (res.statusCode == 200) {
                token = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                if (token) {
                    _developerToken = token;
                    [[NSUserDefaults standardUserDefaults] setObject:token forKey:developerTokenDefaultsKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }else{
                Log(@"Error: %@, %s",error,__FILE__);
            }
        }] resume];
    }

}
- (void)requestUserToken{
    [SKCloudServiceController requestAuthorization:^(SKCloudServiceAuthorizationStatus status) {
        SKCloudServiceController *controller = [[SKCloudServiceController  alloc] init];
        if (status == SKCloudServiceAuthorizationStatusAuthorized) {
            [[NSNotificationCenter defaultCenter] postNotificationName:userAuthorizedNotification object:nil];
            //请求userToken 并缓存到默认设置
            [controller requestUserTokenForDeveloperToken:self.developerToken completionHandler:^(NSString * _Nullable userToken, NSError * _Nullable error) {
                if (userToken) {
                    _userToken = userToken;
                    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
                    [userDef setObject:userToken forKey:userTokenUserDefaultsKey];
                    [userDef synchronize];
                }
            }];
            
        }
    }];
}

- (void)requestStorefront{
    [SKCloudServiceController requestAuthorization:^(SKCloudServiceAuthorizationStatus status) {
        SKCloudServiceController *controller = [[SKCloudServiceController  alloc] init];
        if (status == SKCloudServiceAuthorizationStatusAuthorized) {
            //获取绑定的商店  并缓存
            [controller requestStorefrontCountryCodeWithCompletionHandler:^(NSString * _Nullable storefrontCountryCode, NSError * _Nullable error) {
                if (!error && storefrontCountryCode) {
                    _storefront = storefrontCountryCode;
                    [[NSUserDefaults standardUserDefaults] setObject:storefrontCountryCode forKey:storefrontDefaultsKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }];
            
        }
    }];
}
@end
