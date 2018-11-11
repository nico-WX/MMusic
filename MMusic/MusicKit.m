//
//  MusicKit.m
//  MMusic
//
//  Created by Magician on 2018/6/25.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import "MusicKit.h"

static MusicKit* _instance;

@implementation MusicKit
-(instancetype)init{
    if (self = [super init]) {
        _catalog = [Catalog new];
        _library = [Library new];
    }
    return self;
}
+(instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:zone] init];
    });
    return _instance;
}
@end
