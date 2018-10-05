//
//  AuthorizationManager.h
//  MMusic
//
//  Created by Magician on 2017/11/10.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>

/**授权处理*/
@interface AuthorizationManager : NSObject<NSCopying,NSMutableCopying>
/**地区商店代码*/
@property(nonatomic, copy, readonly) NSString *storefront;
/**开发者令牌*/
@property(nonatomic, copy, readonly) NSString *developerToken;
/**用户令牌*/
@property(nonatomic, copy, readonly) NSString *userToken;

/**单例*/
+(instancetype) shareManager;
@end
