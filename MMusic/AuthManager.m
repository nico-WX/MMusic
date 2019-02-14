
#import "AuthManager.h"
#import "NSURLRequest+CreateURLRequest.h"
#import <StoreKit/StoreKit.h>

//Token缓存Key
static NSString* const k_userTokenKey       = @"userTokenUserDefaultsKey";
static NSString* const k_developerTokenKey  = @"developerTokenDefaultsKey";
static NSString* const k_storefrontKey      = @"storefrontDefaultsKey";

//通知
NSString *const developerTokenDidExpireNotification  = @"developerTokenExpire";           //开发者Token 过期
NSString *const developerTokenDidUpdateNotification = @"developerTokenUpdated";          //开发者Token 已经更新
NSString *const userTokenIssueNotification        = @"userTokenIssueOrNotAccepted";    //userToken  问题(未订阅,修改设置等)
NSString *const userTokenUpdatedNotification      = @"userTokenUpdated";               //userToken  更新

@interface AuthManager()<SKCloudServiceSetupViewControllerDelegate>
@property(nonatomic, strong)SKCloudServiceSetupViewController* subscriptionViewController;  //订阅apple music会员视图控制器, 其内容通过网络加载

@end

static NSString *const devToken =  @"eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NiIsInR5cGUiOiJKV1QiLCJraWQiOiJTMkhFRlRWM0o5In0.eyJpc3MiOiJWOVc4MzdZNkFWIiwiaWF0IjoxNTQ3OTg5MDI4LCJleHAiOjE1NjM1NDEwMjh9.WMdZ1XSwfm2xG27CY9KbdiZXKKaQzfjl5YPUL_kZW46aoGDZ8H24k6mtGlqK616XUkbW1WqQYLTlBQuEt4t7tQ";

static id _instance;
@implementation AuthManager

@synthesize developerToken  = _developerToken;
@synthesize userToken       = _userToken;
@synthesize storefront      = _storefront;

# pragma mark 初始化及单例实现
- (instancetype)init{
    if (self = [super init]) {

        //设置Token
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        _developerToken = [userDefaults objectForKey:k_developerTokenKey];
        if (!_developerToken) {
            _developerToken = devToken;
            [userDefaults setObject:_developerToken forKey:k_developerTokenKey];
            [userDefaults synchronize];
        }
        _userToken = [userDefaults objectForKey:k_userTokenKey];
        if (!_userToken) {
            [self loadUserToken];
        }
        _storefront = [userDefaults objectForKey:k_storefrontKey];
        if (!_storefront) {
            [self loadStorefront];
        }


        //开发者Token过期消息
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserverForName:developerTokenDidExpireNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            NSLog(@"收到开发者Token过期通知");
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:k_developerTokenKey];

        }];

        //userToken 异常, 可能修改设置或者未订阅服务等
        [center addObserverForName:userTokenIssueNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            NSLog(@"监听到 <userTokenIssueNotification> 消息");
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:k_userTokenKey];
            [self loadUserToken];
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
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

- (id)copyWithZone:(NSZone *)zone{
    return _instance;
}


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:developerTokenDidExpireNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:userTokenIssueNotification object:nil];
}

- (void)loadUserToken{
    [SKCloudServiceController.new requestUserTokenForDeveloperToken:self.developerToken
                                                  completionHandler:^(NSString * _Nullable userToken, NSError * _Nullable error)
    {
         if (userToken) {
             self->_userToken = userToken;
             NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
             [userDefaults setObject:userToken forKey:k_userTokenKey];
             [userDefaults synchronize];
         }
     }];
}

- (void)loadStorefront {
    [SKCloudServiceController.new requestStorefrontCountryCodeWithCompletionHandler:^(NSString * _Nullable storefrontCountryCode, NSError * _Nullable error) {
        if (storefrontCountryCode) {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:storefrontCountryCode forKey:k_storefrontKey];
            [userDefaults synchronize];
            self->_storefront = storefrontCountryCode;
        }
    }];
}

- (void)checkAuthTokenAvailability{

    //以下检查token 有效性
    NSString *testAuthPath = @"https://api.music.apple.com/v1/me/library/playlists";
    NSURLRequest *request = [NSURLRequest createRequestWithURLString:testAuthPath setupUserToken:YES];
    [self dataTaskWithRequest:request handler:^(NSDictionary *json, NSHTTPURLResponse *response) {

        NSLog(@"check auth statusCode =%ld",response.statusCode);
        if (response.statusCode == 403) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:k_userTokenKey];
        }
        if (response.statusCode == 401) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:k_developerTokenKey];
        }

    }];
}

//检查授权
- (void)checkAuthorization{
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
//检查服务
- (void)checkCloudServiceState{
    //检查用户订阅状态
    [SKCloudServiceController.new requestCapabilitiesWithCompletionHandler:^(SKCloudServiceCapability capabilities, NSError * _Nullable error) {
        if (capabilities == SKCloudServiceCapabilityNone) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showSubscriptionView];    //未订阅, 显示订阅视图控制器
            });
        }

//        if (capabilities & SKCloudServiceCapabilityMusicCatalogSubscriptionEligible) {
//            NSLog(@"合格订阅者");
//        }
//        if (capabilities & SKCloudServiceCapabilityMusicCatalogPlayback) {
//            NSLog(@"可以回放");
//        }
//        if (capabilities & SKCloudServiceCapabilityAddToCloudMusicLibrary) {
//            NSLog(@"增加云音乐库");
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
