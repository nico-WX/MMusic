//
//  NSURLRequest+Extension.h
//  MMusic
//
//  Created by 🐙怪兽 on 2019/2/18.
//  Copyright © 2019 com.😈. All rights reserved.
//



NS_ASSUME_NONNULL_BEGIN

@interface NSURLRequest (Extension)

+ (NSURLRequest*)createRequestWithURLString:(NSString*)urlString setupUserToken:(BOOL)setupUserToken;
+ (NSURLRequest*)createRequestWithHref:(NSString*)href;

@end

NS_ASSUME_NONNULL_END
