//
//  AuthorizationManager.h
//  MMusic
//
//  Created by Magician on 2017/11/10.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AuthorizationManager : NSObject<NSCopying,NSMutableCopying>
@property(nonatomic, copy) NSString *storefront;
@property(nonatomic, copy) NSString *developerToken;
@property(nonatomic, copy) NSString *userToken;

+(instancetype) shareAuthorizationManager;
@end
