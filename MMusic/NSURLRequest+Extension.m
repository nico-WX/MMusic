//
//  NSURLRequest+Extension.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/2/18.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "NSURLRequest+Extension.h"
#import "AuthManager.h"

@implementation NSURLRequest (Extension)

+ (NSURLRequest*)createRequestWithURLString:(NSString *)urlString setupUserToken:(BOOL)setupUserToken {
    //移除'%' 防止将'%' 重复编码成25
    urlString = [urlString stringByRemovingPercentEncoding];
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

    //设置请求头
    NSString *bearerString = [NSString stringWithFormat:@"Bearer %@",[AuthManager shareManager].developerToken];
    [request setValue:bearerString forHTTPHeaderField:@"Authorization"];
    if (setupUserToken) {
        NSString *userToken = [AuthManager  shareManager].userToken;
        [request setValue:userToken forHTTPHeaderField:@"Music-User-Token"];
    }
    return request;
}
+ (NSURLRequest*)createRequestWithHref:(NSString *)href {
    NSString *path = @"https://api.music.apple.com";
    path = [path stringByAppendingPathComponent:href];
    return [self createRequestWithURLString:path setupUserToken:NO];
}


@end
