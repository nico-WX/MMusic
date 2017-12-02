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
-(NSDictionary*) serializationDataWithResponse:(NSURLResponse* ) response data:(NSData*) data error:(NSError*) error;

@end
