//
//  NSObject+Tool.h
//  MMusic
//
//  Created by Magician on 2017/12/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Tool)

/**统一处理响应头信息,解析响应体 并返回字典(如果有返回)*/
- (NSDictionary*_Nullable) serializationDataWithResponse:(NSURLResponse* _Nullable ) response data:(NSData*_Nullable) data error:(NSError*_Nullable) error;

/**封装了发起任务操作*/
-(void)dataTaskWithdRequest:(NSURLRequest*_Nonnull) request completionHandler:(void(^_Nonnull)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)) handler;

/**替换ImageURL 中的Image大小参数 默认5倍宽高大小*/
-(NSString*_Nonnull) stringReplacingOfString:(NSString*_Nonnull) target height:(int) height width:(int) width;

/**设置请求体中的 请求头*/
-(void)setupAuthorizationWithRequest:(NSMutableURLRequest *_Nonnull)request setupMusicUserToken:(BOOL)needSetupUserToken;

/**通过子路径  创建请求体*/
-(NSURLRequest*_Nonnull) createRequestWithURLString:(NSString*_Nonnull) urlString setupUserToken:(BOOL) setupUserToken;
@end
