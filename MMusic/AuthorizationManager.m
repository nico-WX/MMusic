




#import "AuthorizationManager.h"
#import <StoreKit/StoreKit.h>

//Token缓存Key
NSString* const userTokenUserKey  = @"userTokenUserDefaultsKey";
NSString* const developerTokenKey = @"developerTokenDefaultsKey";
NSString* const storefrontKey     = @"storefrontDefaultsKey";

//通知
NSString* const developerTokenExpireNotification  = @"developerTokenExpire";           //开发者Token 过期
NSString* const developerTokenUpdatedNotification = @"developerTokenUpdated";          //开发者Token 更新
NSString* const userTokenIssueNotification        = @"userTokenIssueOrNotAccepted";    //userToken  问题(未订阅,修改设置等)
NSString* const userTokenUpdatedNotification      = @"userTokenUpdated";               //userToken  更新

@interface AuthorizationManager()<SKCloudServiceSetupViewControllerDelegate>
/**订阅apple music会员页面, 通过网络加载*/
@property(nonatomic, strong)SKCloudServiceSetupViewController* subscriptionViewController;
@end


static AuthorizationManager* _instance;
@implementation AuthorizationManager

@synthesize developerToken  = _developerToken;
@synthesize userToken       = _userToken;
@synthesize storefront      = _storefront;


# pragma mark 初始化及单例实现
-(instancetype)init{
    if (self = [super init]) {

        //检查授权
        [self checkAuthorization];

        //开发者Token 过期消息 删除旧的developerToken  并请求一个新的
        [[NSNotificationCenter defaultCenter] addObserverForName:developerTokenExpireNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            //移除过期DeveloperToken
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:developerTokenKey];

            //主动请求新的developerToken
           [self requestDeveloperToken];
        }];


        //userToken 异常, 可能修改设置或者未订阅服务等
        [[NSNotificationCenter defaultCenter] addObserverForName:userTokenIssueNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:userTokenUserKey];
            //[self requestUserToken];
        }];
        //国家区域变化
    }
    return self;
}

+(instancetype)shareManager{
    return [[self alloc] init];
}

+(instancetype)allocWithZone:(struct _NSZone *)zone{
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
        _developerToken = [[NSUserDefaults standardUserDefaults] objectForKey:developerTokenKey];
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
        //[[NSUserDefaults standardUserDefaults] removeObjectForKey:userTokenUserDefaultsKey];
        _userToken = [[NSUserDefaults standardUserDefaults] objectForKey:userTokenUserKey];
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
        _storefront = [[NSUserDefaults standardUserDefaults] objectForKey:storefrontKey];
        if (!_storefront) {
            [self requestStorefront];
        }
    }
    return _storefront;
}

#pragma mark - 从网络请求token /地区代码
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
                    //self->_developerToken = token;
                    [[NSUserDefaults standardUserDefaults] setObject:token forKey:developerTokenKey];
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
            [SKCloudServiceController.new requestUserTokenForDeveloperToken:self.developerToken completionHandler:^(NSString * _Nullable userToken, NSError * _Nullable error) {
                if (userToken) {
                    Log(@"userToken: %@",userToken);
                    [[NSUserDefaults standardUserDefaults] setObject:userToken forKey:userTokenUserKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [[NSNotificationCenter defaultCenter] postNotificationName:userTokenUpdatedNotification object:nil];
                }else{
                    Log(@"请求用户Token错误: %@",error.domain);
                }
            }];
        }
    }];
}

- (void)requestStorefront{
    [SKCloudServiceController requestAuthorization:^(SKCloudServiceAuthorizationStatus status) {
        if (status == SKCloudServiceAuthorizationStatusAuthorized) {
            //获取绑定的商店  并缓存
            [SKCloudServiceController.new requestStorefrontCountryCodeWithCompletionHandler:^(NSString * _Nullable storefrontCountryCode, NSError * _Nullable error) {
                if (!error && storefrontCountryCode) {
                    self->_storefront = storefrontCountryCode;
                    [[NSUserDefaults standardUserDefaults] setObject:storefrontCountryCode forKey:storefrontKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }];
        }
    }];
}

//检查授权(先检查用户授权,然后检查Appe Music 订阅状态)
-(void)checkAuthorization{
    //验证用户授权状态
    [SKCloudServiceController requestAuthorization:^(SKCloudServiceAuthorizationStatus status) {
        switch (status) {

                //授权获取音乐资料库
            case SKCloudServiceAuthorizationStatusAuthorized:{
                //检查用户订阅状态
                [SKCloudServiceController.new requestCapabilitiesWithCompletionHandler:^(SKCloudServiceCapability capabilities, NSError * _Nullable error) {

                    switch (capabilities) {
                        case SKCloudServiceCapabilityNone:
                            //没有订阅 显示订阅视图
                            [self showSubscriptionView];
                            break;
                        case SKCloudServiceCapabilityMusicCatalogPlayback:
                            break;
                        case SKCloudServiceCapabilityAddToCloudMusicLibrary:
                            break;
                        case SKCloudServiceCapabilityMusicCatalogSubscriptionEligible:
                            break;
                    }
                }];
            }
                break;

            case SKCloudServiceAuthorizationStatusDenied:{
                //拒绝授权
                [self showHUDToMainWindowFromText:@"用户拒绝获取音乐库信息,请手动开启"];
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

//显示订阅视图
-(void) showSubscriptionView{

    self.subscriptionViewController = [[SKCloudServiceSetupViewController alloc] init];
    self.subscriptionViewController.delegate = self;
    //页面设置
    NSDictionary *infoDict = @{SKCloudServiceSetupOptionsMessageIdentifierKey:SKCloudServiceSetupMessageIdentifierJoin,
                           SKCloudServiceSetupOptionsActionKey : SKCloudServiceSetupActionSubscribe
                           };

    [self.subscriptionViewController loadWithOptions:infoDict completionHandler:^(BOOL result, NSError * _Nullable error) {
        if (result) {
            //加载页面到主窗口
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication].keyWindow addSubview:self.subscriptionViewController.view];
            });
        }
    }];
}

#pragma mark - SKCloudServiceSetupViewControllerDelegate
-(void)cloudServiceSetupViewControllerDidDismiss:(SKCloudServiceSetupViewController *)cloudServiceSetupViewController{
    [cloudServiceSetupViewController.view removeFromSuperview];
}


@end
