//
//  AuthorizationManager.m
//  MMusic
//
//  Created by Magician on 2017/11/10.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "AuthorizationManager.h"
#import <StoreKit/StoreKit.h>

//Token缓存Key
NSString * const userTokenUserDefaultsKey  = @"userTokenUserDefaultsKey";
NSString * const developerTokenDefaultsKey = @"developerTokenDefaultsKey";
NSString * const storefrontDefaultsKey     = @"storefrontDefaultsKey";

//开发者Token过期通知
NSString * const developerTokenExpireNotification  = @"developerTokenExpire";
//userToken  问题(未订阅,修改设置等)
NSString * const userTokenIssueNotification        = @"userTokenIssueOrNotAccepted";

//token 已经更新通知
NSString * const developerTokenUpdatedNotification = @"developerTokenUpdated";
NSString * const userTokenUpdatedNotification      = @"userTokenUpdated";

@interface AuthorizationManager()
@end

static AuthorizationManager *_instance;
@implementation AuthorizationManager
@synthesize developerToken  = _developerToken;
@synthesize userToken       = _userToken;
@synthesize storefront      = _storefront;


# pragma mark 初始化及单例实现
-(instancetype)init{
    if (self = [super init]) {

        //开发者Token 过期消息 删除旧的developerToken  并请求一个新的
        [[NSNotificationCenter defaultCenter] addObserverForName:developerTokenExpireNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            //移除过期DeveloperToken
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:developerTokenDefaultsKey];

            //主动请求新的developerToken
            [self requestDeveloperToken];
        }];

        //userToken 异常, 可能修改设置或者未订阅服务等
        [[NSNotificationCenter defaultCenter] addObserverForName:userTokenIssueNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:userTokenUserDefaultsKey];
            [self requestUserToken];
        }];
        //国家区域变化
    }
    return self;
}

+(instancetype)shareAuthorizationManager{
    return [[self alloc] init];
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

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:developerTokenExpireNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:userTokenIssueNotification object:nil];
}


#pragma mark layz
-(NSString *)developerToken{
    if (!_developerToken) {
        _developerToken = [[NSUserDefaults standardUserDefaults] objectForKey:developerTokenDefaultsKey];
#warning The token is set manually
        _developerToken = @"eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NiIsInR5cGUiOiJKV1QiLCJraWQiOiJTMkhFRlRWM0o5In0.eyJpc3MiOiJWOVc4MzdZNkFWIiwiaWF0IjoxNTI3NTAwMjY0LCJleHAiOjE1NDMwNTIyNjR9.UtcI1T7Xu1qizH7XR_91Xyd7KNkUkPh318l6k11Jap5S8TW2pFtL-mjCrG9N42jdvmrkA-oIaKzvyN4oKnBwnQ";
        if (!_developerToken) {
            [self requestDeveloperToken];
        }
    }
    return _developerToken;
}

-(NSString *)userToken{
    if (!_userToken) {
        _userToken = [[NSUserDefaults standardUserDefaults] objectForKey:userTokenUserDefaultsKey];
        if (!_userToken) {
            //本地无Token,  网络请求
            [self requestUserToken];
            [[NSNotificationCenter defaultCenter] postNotificationName:userTokenIssueNotification object:nil];
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

#pragma mark - 从网络请求token 地区代码
/**请求开发者Token 并缓存在默认设置*/
- (void)requestDeveloperToken{
#warning DeveloperTokenURL no set!
    NSURL *url = [NSURL URLWithString:@"http://127.0.0.1:5000/jwt"];
        [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSHTTPURLResponse *res = (NSHTTPURLResponse*) response;
            if (res.statusCode == 200) {
                NSString *token = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

                if (token) {
                    Log(@"request new DeveloperToken: %@",token);
                    self->_developerToken = token;
                    [[NSUserDefaults standardUserDefaults] setObject:token forKey:developerTokenDefaultsKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [[NSNotificationCenter defaultCenter] postNotificationName:developerTokenUpdatedNotification object:nil];
                }
            }else{
                Log(@"request Developer Token Error: %@",error);
            }
        }] resume];
}

/**请求用户Token*/
- (void)requestUserToken{
    [SKCloudServiceController requestAuthorization:^(SKCloudServiceAuthorizationStatus status) {
        //用户授权获取 云服内容
        if (status == SKCloudServiceAuthorizationStatusAuthorized) {
            Log(@"授权云服务内容");
            //请求userToken 并缓存到默认设置
            SKCloudServiceController *controller = [SKCloudServiceController new];
            [controller requestUserTokenForDeveloperToken:self.developerToken completionHandler:^(NSString * _Nullable userToken, NSError * _Nullable error) {
                if (userToken) {
                    Log(@"userToken: %@",userToken);
                    self->_userToken = userToken;
                    [[NSUserDefaults standardUserDefaults] setObject:userToken forKey:userTokenUserDefaultsKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [[NSNotificationCenter defaultCenter] postNotificationName:userTokenUpdatedNotification object:nil];
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
                    self->_storefront = storefrontCountryCode;
                    [[NSUserDefaults standardUserDefaults] setObject:storefrontCountryCode forKey:storefrontDefaultsKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }];
            
        }
    }];
}



@end
