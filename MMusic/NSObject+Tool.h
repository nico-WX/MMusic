//
//  NSObject+Tool.h
//  MMusic
//
//  Created by Magician on 2017/12/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


//请求数据回调
typedef void(^RequestCallBack)(NSDictionary* json, NSHTTPURLResponse* response);


@interface NSObject (Tool)

/**
统一处理响应头信息,处理授权Token 解析响应体 并返回字典(如果有返回)
 */
- (NSDictionary*_Nullable)serializationDataWithResponse:(NSURLResponse* _Nullable)response
                                                   data:(NSData*_Nullable)data
                                                  error:(NSError*_Nullable)error;


/**
 封装请求操作 通过回调返回json数据
 */
- (void)dataTaskWithRequest:(NSURLRequest*)request handler:(RequestCallBack)handle;


@end


