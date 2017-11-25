//
//  Preview.m
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "Preview.h"
#import <MJExtension.h>

@implementation Preview

-(instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super init]) {
        [self mj_setKeyValues:dict];
    }
    return self;
}
+(instancetype)previewWithDict:(NSDictionary *)dict{
    return [[self alloc] initWithDict:dict];
}
@end
