//
//  JSONKey.m
//  MMusic
//
//  Created by Magician on 2018/7/28.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import "JSONKey.h"

static JSONKey* _instance;
@implementation JSONKey
-(instancetype)init{
    if (self = [super init]) {
        _data       = @"data";
        _results    = @"results";
        _identifier = @"id";
        _attributes = @"attributes";
        _type       = @"type";
        _songs      = @"songs";
        _albums     = @"albums";
    }
    return self;
}
+(instancetype)allocWithZone:(struct _NSZone *)zone{
    if (!_instance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _instance = [super allocWithZone:zone];
        });
    }
    return _instance;
}
@end
