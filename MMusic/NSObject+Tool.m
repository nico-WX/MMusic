//
//  NSObject+Tool.m
//  MMusic
//
//  Created by Magician on 2017/12/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import <UIImageView+WebCache.h>

#import "NSString+Replace.h"
#import "NSObject+Tool.h"
#import "AuthManager.h"


@implementation NSObject (Tool)

//统一解析响应体,处理异常等.
- (NSDictionary *)serializationDataWithResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *)error {
    if (error) Log(@"请求错误  error: %@",error.localizedDescription);

    NSDictionary *json;
    NSHTTPURLResponse *res = (NSHTTPURLResponse*)response;
    switch (res.statusCode) {
        case 200:
            if (data) {
                json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                if (error) Log(@"Serialization Error:%@",error);
            }
            break;
        case 400:
            //[self showHUDToMainWindowFromText:@"400 请刷新"];
            break;
        case 401:{
            //开发者Token 问题
            //NSLog(@"开发者令牌授权过期");
            [[NSNotificationCenter defaultCenter] postNotificationName:developerTokenInvalidNotification object:nil];
        }
            break;
        case 403:{
            //userToken 问题
            //NSLog(@"用户令牌授权过期");
            [[NSNotificationCenter defaultCenter] postNotificationName:userTokenInvalidNotification object:nil];
        }
            break;

        default:
            break;
    }
    return json;
}

//封装发起任务请求操作,通过block 回调返回数据.
- (void)dataTaskWithRequest:(NSURLRequest*)request handler:(RequestCallBack)handle {
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        //统一处理返回的数据,响应体等,不管是否有回调, 在解析中都处理请求结果.
        NSDictionary *json = [self serializationDataWithResponse:response data:data error:error];
        if (handle) {
            mainDispatch(^{
                handle(json,(NSHTTPURLResponse*)response);
            });
        }
    }] resume];
}

@end
