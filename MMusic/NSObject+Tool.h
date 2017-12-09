//
//  NSObject+Tool.h
//  MMusic
//
//  Created by Magician on 2017/12/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Tool)

/**解析响应*/
- (NSDictionary*_Nullable) serializationDataWithResponse:(NSURLResponse* _Nullable ) response data:(NSData*_Nullable) data error:(NSError*_Nullable) error;

/**封装了发起任务操作*/
-(void)dataTaskWithdRequest:(NSURLRequest*_Nonnull) request completionHandler:(void(^_Nonnull)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)) handler;
//stringByReplacingOccurrencesOfString:@"{w}" withString

/**替换ImageURL 中的Image大小参数 默认5倍宽高大小*/
-(NSString*_Nonnull) stringReplacingOfString:(NSString*_Nonnull) target height:(int) height width:(int) width;


@end
