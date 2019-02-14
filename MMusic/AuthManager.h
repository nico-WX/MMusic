//
//  令牌/授权 管理
//  AuthManager.h
//  MMusic
//
//  Created by Magician on 2017/11/10.
//  Copyright © 2017年 com.😈. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface AuthManager : NSObject

@property(nonatomic, copy, readonly) NSString *storefront;
@property(nonatomic, copy, readonly) NSString *developerToken;
@property(nonatomic, copy, readonly) NSString *userToken;


+ (instancetype)shareManager;

//状态检查
- (void)checkAuthorization;
- (void)checkAuthTokenAvailability;

//- (void)needUpdateUserToken;
//- (void)needUpdateDeveloperToken;
@end
