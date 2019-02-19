//
//  AuthManager.h
//  MMusic
//
//  Created by Magician on 2017/11/10.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Single.h"

// update
extern NSString *const cloudServiceDidUpdateNotification;
extern NSString *const authorizationDidUpdateNotification;

// reload token
extern NSString *const userTokenInvalidNotification;
extern NSString *const developerTokenInvalidNotification;


@interface AuthManager : NSObject

@property(nonatomic, copy, readonly) NSString *storefront;
@property(nonatomic, copy, readonly) NSString *developerToken;
@property(nonatomic, copy, readonly) NSString *userToken;

SingleInterface(Manager); // 单例方法声明
@end
