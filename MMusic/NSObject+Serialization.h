//
//  NSObject+Serialization.h
//  MMusic
//
//  Created by Magician on 2017/11/29.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Serialization)

/**解析响应*/
- (NSDictionary*_Nullable) serializationDataWithResponse:(NSURLResponse* _Nullable ) response data:(NSData*_Nullable) data error:(NSError*_Nullable) error;

/**封装了发起任务操作*/
-(void)dataTaskWithdRequest:(NSURLRequest*) request completionHandler:(void(^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)) handler;
//stringByReplacingOccurrencesOfString:@"{w}" withString

/**替换ImageURL 中的Image大小参数 默认5倍宽高大小*/
-(NSString*) stringReplacingOfString:(NSString*) target height:(int) height width:(int) width;

@end
