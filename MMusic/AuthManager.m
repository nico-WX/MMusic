


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
NSString *const tokenDidUpdatedNotification         = @"tokenDidUpdatedNotification";

@interface AuthManager()<SKCloudServiceSetupViewControllerDelegate>
//当前状态
@property(nonatomic, assign) MPMediaLibraryAuthorizationStatus libraryAuthorizationStatus;
@property(nonatomic, assign) SKCloudServiceAuthorizationStatus cloudAuthorizationStatus;
@property(nonatomic, assign) SKCloudServiceCapability          cloudServiceCapability;

//订阅apple music会员视图控制器, 其内容通过网络加载
@property(nonatomic, strong)SKCloudServiceSetupViewController *subscriptionViewController;
@property(nonatomic,strong)NSUserDefaults *defaults;
@end

static NSString *const devToken =  @"eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NiIsInR5cGUiOiJKV1QiLCJraWQiOiJTMkhFRlRWM0o5In0.eyJpc3MiOiJWOVc4MzdZNkFWIiwiaWF0IjoxNTUwNTYwODYyLCJleHAiOjE1NjYxMTI4NjJ9.9bHQQjGHZ9fFALH0Kz_DcjnpZtVoHlHTsJey7_jsC4Rxy8ZSSa622b8o6Zsq_cHO7IvJj555YeiggaBVvzc0Sg";

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
            self->_libraryAuthorizationStatus = [MPMediaLibrary authorizationStatus];
            self->_cloudAuthorizationStatus = [SKCloudServiceController authorizationStatus];

            //检查授权状态(Authorization)
            switch (self->_libraryAuthorizationStatus) {
                case MPMediaLibraryAuthorizationStatusDenied:
                case MPMediaLibraryAuthorizationStatusNotDetermined:
                    NSLog(@"当前未授权");
                    [self requestMediaLibraryAuthorization];
                    break;

                default:
                    break;
            }
            switch (self->_cloudAuthorizationStatus) {
                case SKCloudServiceAuthorizationStatusDenied:
                case SKCloudServiceAuthorizationStatusNotDetermined:
                    NSLog(@"无云服务");
                    [self requestCloudServiceAuthorization];
                    break;

                default:
                    break;
            }

            NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
            //刷新云服务功能
            [center addObserver:self
                       selector:@selector(requestCloudServiceCapabilities)
                           name:SKCloudServiceCapabilitiesDidChangeNotification
                         object:nil];

            // 开发令牌过期 刷新开发者Token
            [center addObserver:self
                       selector:@selector(reloadDeveloperToken)
                           name:developerTokenInvalidNotification
                         object:nil];
            //用户令牌h过期 刷新用户Token
            [center addObserver:self
                       selector:@selector(reloadUserToken)
                           name:userTokenInvalidNotification
                         object:nil];

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
    [center removeObserver:self name:developerTokenInvalidNotification object:nil];
    [center removeObserver:self name:userTokenInvalidNotification object:nil];
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
        [[NSNotificationCenter defaultCenter] postNotificationName:tokenDidUpdatedNotification object:nil];
    }
    _developerToken = token;
}
- (void)fetchUserToken{
    NSString *token = [self.defaults valueForKey:userTokenDefaultsKey];
    if (!token) {
        [SKCloudServiceController.new requestUserTokenForDeveloperToken:self.developerToken completionHandler:^(NSString * _Nullable userToken, NSError * _Nullable error) {
            if (error) {
                NSLog(@"请求userToken 出错 error:%@",error.localizedDescription);
            }else{
                [self.defaults setValue:userToken forKey:userTokenDefaultsKey];
                [self.defaults synchronize];
                self->_userToken = userToken;
                [[NSNotificationCenter defaultCenter] postNotificationName:tokenDidUpdatedNotification object:nil];
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

#pragma mark - 刷新Token(过期后请求新的)
- (void)reloadDeveloperToken{
    //防止多次
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self->_developerToken = nil;
        [self.defaults removeObjectForKey:developerTokenDefaultsKey];
        [self.defaults synchronize];
        [self fetchDeveloperToken];
    });
}
- (void)reloadUserToken{
    //防止多次
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self->_userToken = nil;
        [self.defaults removeObjectForKey:userTokenDefaultsKey];
        [self.defaults synchronize];
        [self fetchUserToken];
    });
}

#pragma mark - Handle Authorization & CloudServiceCapability

//授权处理顺序
// LibriryAuthorization -->  CloudAuthorization -->  CloudCapabilities
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
        [[NSNotificationCenter defaultCenter] postNotificationName:authorizationDidUpdateNotification object:nil];
    }];
}
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
        self.cloudServiceCapability = capabilities;
        switch (capabilities) {
            case SKCloudServiceCapabilityNone:
                //显示订阅
                [self showSubscriptionView];
                break;

            default:
                break;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:cloudServiceDidUpdateNotification object:nil];
    }];
}


#pragma mark - 订阅视图控制器 和代理
- (void)showSubscriptionView{
//    self.subscriptionViewController = [[SKCloudServiceSetupViewController alloc] init];
//    self.subscriptionViewController.delegate = self;
    SKCloudServiceSetupViewController *setupVC = [[SKCloudServiceSetupViewController alloc] init];
    setupVC.delegate = self;
    //页面配置
    NSDictionary *infoDict = @{SKCloudServiceSetupOptionsMessageIdentifierKey:SKCloudServiceSetupMessageIdentifierJoin,
                               SKCloudServiceSetupOptionsActionKey : SKCloudServiceSetupActionSubscribe
                               };
    [/*self.subscriptionViewController*/setupVC loadWithOptions:infoDict completionHandler:^(BOOL result, NSError * _Nullable error) {
        if (result) {
            UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
            [rootVC presentViewController:self.subscriptionViewController animated:YES completion:nil];
        }else{
        }
    }];
}
- (void)cloudServiceSetupViewControllerDidDismiss:(SKCloudServiceSetupViewController *)cloudServiceSetupViewController{
    [cloudServiceSetupViewController.view removeFromSuperview];
    self.subscriptionViewController = nil;
}
@end
