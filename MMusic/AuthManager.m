
#import "AuthManager.h"
#import <StoreKit/StoreKit.h>

//Token缓存Key
static NSString* const userTokenDefaultsKey       = @"userTokenUserDefaultsKey";
static NSString* const developerTokenDefaultsKey  = @"developerTokenDefaultsKey";
static NSString* const storefrontDefaultsKey      = @"storefrontDefaultsKey";

//通知
NSString *const cloudServiceDidUpdateNotification = @"cloudServiceDidUpdateNotification";
NSString *const authorizationDidUpdateNotification = @"authorizationDidUpdateNotification";

@interface AuthManager()<SKCloudServiceSetupViewControllerDelegate>
//订阅apple music会员视图控制器, 其内容通过网络加载
@property(nonatomic, strong)SKCloudServiceSetupViewController *subscriptionViewController;
@end

static NSString *const devToken =  @"eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NiIsInR5cGUiOiJKV1QiLCJraWQiOiJTMkhFRlRWM0o5In0.eyJpc3MiOiJWOVc4MzdZNkFWIiwiaWF0IjoxNTQ3OTg5MDI4LCJleHAiOjE1NjM1NDEwMjh9.WMdZ1XSwfm2xG27CY9KbdiZXKKaQzfjl5YPUL_kZW46aoGDZ8H24k6mtGlqK616XUkbW1WqQYLTlBQuEt4t7tQ";

static id _instance;
@implementation AuthManager

@synthesize developerToken = _developerToken;
@synthesize userToken = _userToken;
@synthesize storefront = _storefront;

# pragma mark - init

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

- (instancetype)init{
    if (self = [super init]) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

        [center addObserver:self
                   selector:@selector(requestCloudServiceCapabilities)
                       name:SKCloudServiceCapabilitiesDidChangeNotification
                     object:nil];

        //请求授权
        [self requestMediaLibraryAuthorization];
        [self requestCloudServiceAuthorization];

        // 预先加载Token
        [self fetchUserToken:^(NSString *userToken) {
            self->_userToken = userToken;
        }];
        [self fetchDeveloperToken:^(NSString *developerToken) {
            self->_developerToken = developerToken;
        }];
        [self fetchStoreFront:^(NSString *storeFront) {
            self->_storefront = storeFront;
        }];

    }
    return self;
}
- (id)copyWithZone:(NSZone *)zone{
    return _instance;
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SKCloudServiceCapabilitiesDidChangeNotification object:nil];
}

#pragma getter
- (NSString *)developerToken{
    if (!_developerToken) {
        _developerToken = [[NSUserDefaults standardUserDefaults] valueForKey:developerTokenDefaultsKey];
    }
    return _developerToken;
}
- (NSString *)userToken{
    if (!_userToken) {
        _userToken = [[NSUserDefaults standardUserDefaults] valueForKey:userTokenDefaultsKey];
    }
    return _userToken;
}
- (NSString *)storefront{
    if (_storefront) {
        _storefront = [[NSUserDefaults standardUserDefaults] valueForKey:storefrontDefaultsKey];
    }
    return _storefront;
}


#pragma mark - Handle Token
- (void)fetchDeveloperToken:(void (^)(NSString *developerToken))completion{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults valueForKey:developerTokenDefaultsKey];

    if (token && completion) {
        completion(token);
    }else{
        //网络异步加载Token
        token = devToken;
        [defaults setValue:token forKey:developerTokenDefaultsKey];
        [defaults synchronize];
        if (completion) {
            completion(token);
        }
    }
}
- (void)fetchUserToken:(void (^)(NSString *userToken))completion{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    __block NSString *token = [defaults valueForKey:userTokenDefaultsKey];
    if (token && completion) {
        completion(token);
    }else{
        [self fetchDeveloperToken:^(NSString *developerToken) {
            [SKCloudServiceController.new requestUserTokenForDeveloperToken:developerToken completionHandler:^(NSString * _Nullable userToken, NSError * _Nullable error) {
                token = userToken;
                [defaults setValue:userToken forKey:userTokenDefaultsKey];
                [defaults synchronize];
                if (completion) {
                    completion(token);
                }
            }];
        }];
    }
}
- (void)fetchStoreFront:(void (^)(NSString *storeFront))completion{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    __block NSString *token = [defaults valueForKey:storefrontDefaultsKey];
    if (token && completion) {
        completion(token);
    }else{
        [SKCloudServiceController.new  requestStorefrontCountryCodeWithCompletionHandler:^(NSString * _Nullable storefrontCountryCode, NSError * _Nullable error) {
            token = storefrontCountryCode;
            [defaults setValue:storefrontCountryCode forKey:storefrontDefaultsKey];
            [defaults synchronize];
            if (completion) {
                completion(storefrontCountryCode);
            }
        }];
    }
}

#pragma mark - Handle Authorization & CloudServiceCapability
- (void)requestCloudServiceAuthorization{
    [SKCloudServiceController requestAuthorization:^(SKCloudServiceAuthorizationStatus status) {
        switch (status) {
            case SKCloudServiceAuthorizationStatusNotDetermined:
                break;

            case SKCloudServiceAuthorizationStatusDenied:
                break;

            case SKCloudServiceAuthorizationStatusRestricted:
                break;

            case SKCloudServiceAuthorizationStatusAuthorized:{
                [self requestCloudServiceCapabilities];
                //授权后,才能请求到Token
                [self fetchUserToken:^(NSString *userToken) {
                    self->_userToken = userToken;
                }];
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
