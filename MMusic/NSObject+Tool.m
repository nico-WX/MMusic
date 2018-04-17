//
//  NSObject+Tool.m
//  MMusic
//
//  Created by Magician on 2017/12/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "NSObject+Tool.h"
#import "AuthorizationManager.h"
#import <UIKit/UIKit.h>


extern NSString *developerTokenExpireNotification;
extern NSString *userTokenIssueNotification;
@implementation NSObject (Tool)

//解析响应  如果有返回, 解析Json 数据到字典
-(NSDictionary *)serializationDataWithResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *)error{

    if (error) Log(@"Location Error:%@",error);
    NSDictionary *dict;
    NSHTTPURLResponse *res = (NSHTTPURLResponse*)response;
    switch (res.statusCode) {
        case 200:
            if (data) {
                dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                if (error) Log(@"Serialization Error:%@",error);
            }
            break;
        case 401:
            //开发者Token 问题
            Log(@"授权过期");
            [[NSNotificationCenter defaultCenter] postNotificationName:developerTokenExpireNotification object:nil];
            break;
        case 403:
            //userToken 问题
            [[NSNotificationCenter defaultCenter] postNotificationName:userTokenIssueNotification object:nil];
            break;

        default:
             //Log(@"response info :%@",res);
            break;
    }
    return dict;
}

//封装发起任务请求操作
-(void)dataTaskWithdRequest:(NSURLRequest*) request completionHandler:(void(^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)) handler{
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
        handler(data,response,error);
    }] resume];
}

//替换海报URL中的占位字符串,
-(NSString *)stringReplacingOfString:(NSString *)target height:(int)height width:(int)width{
    //图片大小倍数
    CGFloat times = [UIScreen mainScreen].scale;
    NSString *w = [NSString stringWithFormat:@"%d",(int)((CGFloat)width * times)];
    NSString *h = [NSString stringWithFormat:@"%d",(int)((CGFloat)height * times)]; //注意占位不能是浮点数, 只能是整数, 不然报CFNetwork 385错误
    target = [target stringByReplacingOccurrencesOfString:@"{h}" withString:h];
    target = [target stringByReplacingOccurrencesOfString:@"{w}" withString:w];
    return target;
}

/**设置请求头*/
-(void)setupAuthorizationWithRequest:(NSMutableURLRequest *)request setupMusicUserToken:(BOOL)needSetupUserToken{

    //设置开发者Token 请求头
    NSString *developerToken = [AuthorizationManager shareAuthorizationManager].developerToken;
    if (developerToken) {
        developerToken = [NSString stringWithFormat:@"Bearer %@",developerToken];
        [request setValue:developerToken forHTTPHeaderField:@"Authorization"];
    }else{
        Log(@"无法获得开发者Token!");
    }

    //个性化请求 设置UserToken 请求头
    if (needSetupUserToken == YES) {
        NSString *userToken = [AuthorizationManager shareAuthorizationManager].userToken;
        if (userToken){
            [request setValue:userToken forHTTPHeaderField:@"Music-User-Token"];
            //Log(@"userToken: %@",userToken);
        }else Log(@"无法获得userToken");
    }
}

/**通过urlString 生成请求体 并设置请求头*/
-(NSURLRequest*) createRequestWithURLString:(NSString*) urlString setupUserToken:(BOOL) setupUserToken{
    //转换URL中文及空格
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    //设置请求头
    [self setupAuthorizationWithRequest:request setupMusicUserToken:setupUserToken];
    return request;
}

@end
