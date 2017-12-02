//
//  NSObject+Serialization.m
//  MMusic
//
//  Created by Magician on 2017/11/29.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "NSObject+Serialization.h"
#import <UIKit/UIKit.h>

extern NSString *developerTokenExpireNotification;

@implementation NSObject (Serialization)

-(NSDictionary *)serializationDataWithResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *)error{
    if (error) {
        Log(@"Error:%@",error);
    }
    NSDictionary *dict;
    NSHTTPURLResponse *res = (NSHTTPURLResponse*) response;
    Log(@"status:%ld",res.statusCode);
    if (res.statusCode == 200 && data) {
        dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (error) Log(@"Serialization Error:%@",error);
    }else if (res.statusCode == 401) {
        [[NSNotificationCenter defaultCenter] postNotificationName:developerTokenExpireNotification object:nil];
    }
    else{
        Log(@"response info :%@",res);
    }
    return dict;
}
@end
