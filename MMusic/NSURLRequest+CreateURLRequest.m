//
//  NSURLRequest+CreateURLRequest.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/4.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "NSURLRequest+CreateURLRequest.h"
#import "AuthManager.h"

@implementation NSURLRequest (CreateURLRequest)
/**通过urlString 生成请求体 并设置请求头*/
+ (instancetype)createRequestWithURLString:(NSString*)urlString setupUserToken:(BOOL)setupUserToken {
    //urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];//转换URL中文及空格 (有二次转码问题)

    //移除 '%' 防止将'%' 重复编码成25
    urlString = [urlString stringByRemovingPercentEncoding];
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

    //设置请求头
    NSString *devToken = AuthManager.shareManager.developerToken;
    if (devToken) {
        devToken = [NSString stringWithFormat:@"Bearer %@",devToken];
        [request setValue:devToken forHTTPHeaderField:@"Authorization"];
    }else
        [self showHUDToMainWindowFromText:@"无法获得开发者Token"];

    if (YES == setupUserToken) {
        NSString *userToken = AuthManager.shareManager.userToken;
        NSLog(@"userToken:=%@",userToken);
        if (userToken) {
            [request setValue:userToken forHTTPHeaderField:@"Music-User-Token"];
        }else
            [self showHUDToMainWindowFromText:@"无法获得用户令牌"];
    }
    return request;
}

+ (instancetype)createRequestWithHref:(NSString *)href {
    NSString *path = @"https://api.music.apple.com";
    path = [path stringByAppendingPathComponent:href];
    return [self createRequestWithURLString:path setupUserToken:YES];
}

@end
