//
//  Genre.m
//  MMusic
//
//  Created by Magician on 2017/12/1.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "Genre.h"

@implementation Genre
- (instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super initWithDict:dict]) {
        [self mj_setKeyValues:[dict valueForKey:JSONAttributesKey]];
    }
    return self;
}

@end
