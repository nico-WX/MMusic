//
//  NSURLRequest+CreateURLRequest.h
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/4.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURLRequest (CreateURLRequest)
+ (instancetype)createRequestWithURLString:(NSString*)urlString setupUserToken:(BOOL)setupUserToken;
+ (instancetype)createRequestWithHref:(NSString*)href;
@end

NS_ASSUME_NONNULL_END
