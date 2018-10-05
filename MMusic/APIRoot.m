//
//  APIRoot.m
//  MMusic
//
//  Created by Magician on 2018/7/26.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import "APIRoot.h"

@implementation APIRoot
-(instancetype)init{
    if (self = [super init]) {
        _rootPath = @"https://api.music.apple.com/v1/";
    }
    return self;
}
@end
