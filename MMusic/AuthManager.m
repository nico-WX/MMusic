
#import "AuthManager.h"
#import <StoreKit/StoreKit.h>

//Token缓存Key
static NSString* const k_userTokenKey  = @"userTokenUserDefaultsKey";
static NSString* const k_developerTokenKey = @"developerTokenDefaultsKey";
static NSString* const k_storefrontKey     = @"storefrontDefaultsKey";


//通知
NSString *const developerTokenExpireNotification  = @"developerTokenExpire";           //开发者Token 过期
NSString *const developerTokenUpdatedNotification = @"developerTokenUpdated";          //开发者Token 更新
NSString *const userTokenIssueNotification        = @"userTokenIssueOrNotAccepted";    //userToken  问题(未订阅,修改设置等)
NSString *const userTokenUpdatedNotification      = @"userTokenUpdated";               //userToken  更新

@interface AuthManager()<SKCloudServiceSetupViewControllerDelegate>
@property(nonatomic, strong)SKCloudServiceSetupViewController* subscriptionViewController;  //订阅apple music会员视图控制器, 其内容通过网络加载

@end



static AuthManager *_instance;
@implementation AuthManager

@synthesize developerToken  = _developerToken;
@synthesize userToken       = _userToken;
@synthesize storefront      = _storefront;

# pragma mark 初始化及单例实现
- (instancetype)init{
    if (self = [super init]) {
        //检查授权和账户功能
        [self checkAuthorization];

        //开发者Token 过期消息 删除旧的developerToken  并请求一个新的
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserverForName:developerTokenExpireNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            NSLog(@"收到开发者Token过期通知");
            //移除过期DeveloperToken
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:k_developerTokenKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            //请求新的开发Token
            [self requestDeveloperToken];
        }];

        //userToken 异常, 可能修改设置或者未订阅服务等
        [center addObserverForName:userTokenIssueNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:k_userTokenKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            NSLog(@"监听到 <userTokenIssueNotification> 消息");
            [self requestUserToken];
        }];

    }
    return self;
}

+ (instancetype)shareManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_instance) {
            _instance = [[super allocWithZone:zone] init];
        }
    });
    return _instance;
}

- (id)copyWithZone:(NSZone *)zone{
    return _instance;
}

- (id)mutableCopyWithZone:(NSZone *)zone{
    return _instance;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:developerTokenExpireNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:userTokenIssueNotification object:nil];
}

#pragma mark getter
- (NSString *)developerToken{
    if (!_developerToken) {
        _developerToken = [[NSUserDefaults standardUserDefaults] objectForKey:k_developerTokenKey];
#warning The token is set manually
        _developerToken = @"eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NiIsInR5cGUiOiJKV1QiLCJraWQiOiJTMkhFRlRWM0o5In0.eyJpc3MiOiJWOVc4MzdZNkFWIiwiaWF0IjoxNTQzMDUyODU1LCJleHAiOjE1NTg2MDQ4NTV9.619j4QOH2KxlK62tmQlMzlu-pbbLc7EmQoqk-dNsc8f2gmPDF2nxWhpADvPk7Rc_Jv9M7lh6Bgu4123swDm9lA";
        if (!_developerToken) {
            [self requestDeveloperToken];
        }
    }
    return _developerToken;
}

- (NSString *)userToken{
    if (!_userToken) {
        _userToken = [[NSUserDefaults standardUserDefaults] objectForKey:k_userTokenKey];
        Log(@"userToken: %@",_userToken);
        if (!_userToken) {
            //本地无Token,  网络请求
            [self requestUserToken];
        }
    }
    return _userToken;
}

- (NSString *)storefront{
    if (!_storefront) {
        _storefront = [[NSUserDefaults standardUserDefaults] objectForKey:k_storefrontKey];
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
                    [[NSUserDefaults standardUserDefaults] setObject:token forKey:k_developerTokenKey];
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
    NSLog(@"请求用户Token begin!");
    [SKCloudServiceController.new requestUserTokenForDeveloperToken:self.developerToken completionHandler:^(NSString * _Nullable userToken, NSError * _Nullable error) {
        if (userToken) {
            Log(@"userToken: %@",userToken);
            [[NSUserDefaults standardUserDefaults] setObject:userToken forKey:k_userTokenKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[NSNotificationCenter defaultCenter] postNotificationName:userTokenUpdatedNotification object:nil];
        }else{
            Log(@"请求用户Token错误: %@",error.domain);
        }
    }];
}

- (void)requestStorefront{
    //获取绑定的商店  并缓存
    [SKCloudServiceController.new requestStorefrontCountryCodeWithCompletionHandler:^(NSString * _Nullable storefrontCountryCode, NSError * _Nullable error) {
        if (!error && storefrontCountryCode) {
            self->_storefront = storefrontCountryCode;
            [[NSUserDefaults standardUserDefaults] setObject:storefrontCountryCode forKey:k_storefrontKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }];
}

//检查授权(先检查用户授权音乐库权限,然后检查Appe Music 订阅状态)
- (void)checkAuthorization{
    //验证用户授权状态
    [SKCloudServiceController requestAuthorization:^(SKCloudServiceAuthorizationStatus status) {
        switch (status) {
                //授权获取音乐资料库
            case SKCloudServiceAuthorizationStatusAuthorized:
                //检查订阅状态
                [self checkCloudServiceState];
                break;

            case SKCloudServiceAuthorizationStatusDenied:
                //拒绝授权
                [self showHUDToMainWindowFromText:@"用户拒绝获取音乐库信息,请手动开启"];
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

- (void)checkCloudServiceState{
    //检查用户订阅状态
    [SKCloudServiceController.new requestCapabilitiesWithCompletionHandler:^(SKCloudServiceCapability capabilities, NSError * _Nullable error) {
        if (capabilities == SKCloudServiceCapabilityNone) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showSubscriptionView];    //未订阅, 显示订阅视图控制器
            });
        }

//        if (capabilities & SKCloudServiceCapabilityMusicCatalogSubscriptionEligible) {
//            NSLog(@"合格订阅");
//        }
//        if (capabilities & SKCloudServiceCapabilityMusicCatalogPlayback) {
//            NSLog(@"可以回放");
//        }
//        if (capabilities & SKCloudServiceCapabilityAddToCloudMusicLibrary) {
//            NSLog(@"add 云音乐库");
//        }
    }];
}

//显示订阅视图
- (void)showSubscriptionView{

    self.subscriptionViewController = [[SKCloudServiceSetupViewController alloc] init];
    self.subscriptionViewController.delegate = self;

    //页面配置
    NSDictionary *infoDict = @{SKCloudServiceSetupOptionsMessageIdentifierKey:SKCloudServiceSetupMessageIdentifierJoin,
                               SKCloudServiceSetupOptionsActionKey : SKCloudServiceSetupActionSubscribe
                               };

    [self.subscriptionViewController loadWithOptions:infoDict completionHandler:^(BOOL result, NSError * _Nullable error) {
        if (result) {
            [[UIApplication sharedApplication].keyWindow addSubview:self.subscriptionViewController.view];
        }else{
            
        }
    }];
}

#pragma mark - SKCloudServiceSetupViewControllerDelegate
- (void)cloudServiceSetupViewControllerDidDismiss:(SKCloudServiceSetupViewController *)cloudServiceSetupViewController{
    [cloudServiceSetupViewController.view removeFromSuperview];
    self.subscriptionViewController = nil;
}
@end
