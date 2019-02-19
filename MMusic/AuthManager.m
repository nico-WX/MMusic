
#import "AuthManager.h"
#import <StoreKit/StoreKit.h>
#import <JGProgressHUD.h>



//Token缓存Key
static NSString* const userTokenDefaultsKey       = @"userTokenUserDefaultsKey";
static NSString* const developerTokenDefaultsKey  = @"developerTokenDefaultsKey";
static NSString* const storefrontDefaultsKey      = @"storefrontDefaultsKey";

//通知
NSString *const cloudServiceDidUpdateNotification   = @"cloudServiceDidUpdateNotification";
NSString *const authorizationDidUpdateNotification  = @"authorizationDidUpdateNotification";
NSString *const userTokenInvalidNotification        = @"userTokenInvalidNotification";
NSString *const developerTokenInvalidNotification   = @"developerTokenInvalidNotification";

@interface AuthManager()<SKCloudServiceSetupViewControllerDelegate>
//订阅apple music会员视图控制器, 其内容通过网络加载
@property(nonatomic, strong)SKCloudServiceSetupViewController *subscriptionViewController;
@property(nonatomic,strong)NSUserDefaults *defaults;

@property(nonatomic, strong) id userTokenInvalidObs;
@property(nonatomic, strong) id developerTokenInvalidObs;
@end

static NSString *const devToken =  @"eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NiIsInR5cGUiOiJKV1QiLCJraWQiOiJTMkhFRlRWM0o5In0.eyJpc3MiOiJWOVc4MzdZNkFWIiwiaWF0IjoxNTUwNTYwODYyLCJleHAiOjE1NjYxMTI4NjJ9.9bHQQjGHZ9fFALH0Kz_DcjnpZtVoHlHTsJey7_jsC4Rxy8ZSSa622b8o6Zsq_cHO7IvJj555YeiggaBVvzc0Sg";

//static id _instance;
@implementation AuthManager

@synthesize developerToken = _developerToken;
@synthesize userToken = _userToken;
@synthesize storefront = _storefront;

# pragma mark - init

//单例实现
SingleImplementation(Manager);

- (instancetype)init{
    if (self = [super init]) {

        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            self->_defaults = [NSUserDefaults standardUserDefaults];

            NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
            //刷新云服务功能
            [center addObserver:self
                       selector:@selector(requestCloudServiceCapabilities)
                           name:SKCloudServiceCapabilitiesDidChangeNotification
                         object:nil];

            //过期, 运行期间, (token如果过期)只需要运行一次, 防止多次执行
            self->_userTokenInvalidObs = [center addObserverForName:userTokenInvalidNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
                static dispatch_once_t onceToken;
                dispatch_once(&onceToken, ^{
                    [self->_defaults removeObjectForKey:userTokenDefaultsKey];
                    [self requestMediaLibraryAuthorization];
                    [self fetchUserToken];
                });

            }];
            self->_developerTokenInvalidObs = [center addObserverForName:developerTokenInvalidNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
                static dispatch_once_t onceToken;
                dispatch_once(&onceToken, ^{
                    [self->_defaults removeObjectForKey:developerTokenDefaultsKey];
                    [self fetchDeveloperToken];
                });
            }];

            //请求授权
            [self requestMediaLibraryAuthorization];
            [self requestCloudServiceAuthorization];

            //初始化Token
            [self fetchDeveloperToken];
            [self fetchUserToken];
            [self fetchStoreFront];
        });
    }
    return self;
}
- (void)dealloc{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:SKCloudServiceCapabilitiesDidChangeNotification object:nil];
    [center removeObserver:_userTokenInvalidObs];
    [center removeObserver:_developerTokenInvalidObs];
}

#pragma getter
- (NSString *)developerToken{
    if (!_developerToken) {
        _developerToken = [_defaults valueForKey:developerTokenDefaultsKey];
    }
    return _developerToken;
}
- (NSString *)userToken{
    if (!_userToken) {
        _userToken = [_defaults valueForKey:userTokenDefaultsKey];
    }
    return _userToken;
}
- (NSString *)storefront{
    if (_storefront) {
        _storefront = [_defaults valueForKey:storefrontDefaultsKey];
    }
    return _storefront;
}

#pragma mark - load Token
- (void)fetchDeveloperToken{
    NSString *token = [self.defaults valueForKey:developerTokenDefaultsKey];
    if (!token) {
        // 自己的服务器加载Token ...
        token = devToken;
        [self.defaults setValue:token forKey:developerTokenDefaultsKey];
        [self.defaults synchronize];
    }
    _developerToken = token;
}
- (void)fetchUserToken{

    NSString *token = [self.defaults valueForKey:userTokenDefaultsKey];
    if (!token) {
        [SKCloudServiceController.new requestUserTokenForDeveloperToken:self.developerToken completionHandler:^(NSString * _Nullable userToken, NSError * _Nullable error) {
            if (userToken) {
                [self.defaults setValue:userToken forKey:userTokenDefaultsKey];
                [self.defaults synchronize];
                self->_userToken = userToken;
            }

        }];
    }
    _userToken = token;
}
- (void)fetchStoreFront{

    NSString *token = [self.defaults valueForKey:storefrontDefaultsKey];
    if (!token) {

        [SKCloudServiceController.new  requestStorefrontCountryCodeWithCompletionHandler:^(NSString * _Nullable storefrontCountryCode, NSError * _Nullable error) {
            if (storefrontCountryCode.length > 0) {
                [self.defaults setValue:storefrontCountryCode forKey:storefrontDefaultsKey];
                [self.defaults synchronize];
                self->_storefront = storefrontCountryCode;
            }
        }];
    }
    _storefront = token;
}

#pragma mark - Handle Authorization & CloudServiceCapability
- (void)requestCloudServiceAuthorization{
    [SKCloudServiceController requestAuthorization:^(SKCloudServiceAuthorizationStatus status) {
        switch (status) {
            case SKCloudServiceAuthorizationStatusNotDetermined:
                break;

            case SKCloudServiceAuthorizationStatusDenied:
                // 提示授权
                break;

            case SKCloudServiceAuthorizationStatusRestricted:
                break;

            case SKCloudServiceAuthorizationStatusAuthorized:{
                [self requestCloudServiceCapabilities];
                [self fetchUserToken];//授权后,才能请求到userToken
                [self fetchStoreFront];//授权才能请求到店面
            }
                break;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:authorizationDidUpdateNotification object:nil];
    }];
}
- (void)requestCloudServiceCapabilities{
    [SKCloudServiceController.new requestCapabilitiesWithCompletionHandler:^(SKCloudServiceCapability capabilities, NSError * _Nullable error) {
        if (error) {
            NSLog(@"访问云服务功能出错:  error :%@",error.localizedDescription);
        }

        switch (capabilities) {
            case SKCloudServiceCapabilityNone:{
                //显示订阅
                [self showSubscriptionView];
            }
                break;

            default:
                break;
        }

        [[NSNotificationCenter defaultCenter] postNotificationName:cloudServiceDidUpdateNotification object:nil];
    }];
}
- (void)requestMediaLibraryAuthorization{
    [MPMediaLibrary requestAuthorization:^(MPMediaLibraryAuthorizationStatus status) {
        switch (status) {
            case MPMediaLibraryAuthorizationStatusAuthorized:
                [self requestCloudServiceAuthorization];
                break;

            case MPMediaLibraryAuthorizationStatusDenied:{
                NSString *text = @"没有授权访问音乐库,请手动开启";
                JGProgressHUD *hud = [[JGProgressHUD alloc]initWithStyle:JGProgressHUDStyleExtraLight];
                [hud setIndicatorView:nil];
                [hud.textLabel setText:text];
                UIView *window = [UIApplication  sharedApplication].keyWindow;
                [hud showInView:window animated:YES];
                [hud dismissAfterDelay:1.35 animated:YES];

            }
                break;

            default:
                break;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:cloudServiceDidUpdateNotification object:nil];
    }];
}

#pragma mark - 订阅视图控制器 和代理
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
- (void)cloudServiceSetupViewControllerDidDismiss:(SKCloudServiceSetupViewController *)cloudServiceSetupViewController{
    [cloudServiceSetupViewController.view removeFromSuperview];
    self.subscriptionViewController = nil;
}
@end
