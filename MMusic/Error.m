//
//  Error.m
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "Error.h"
#import <MJExtension.h>

@implementation Error

+(NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"identifier":@"id"};
}
+(instancetype)instanceWithDict:(NSDictionary *)dict{
    return [[self alloc] initWithDict:dict];
}

-(instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super init]) {
        [self mj_setKeyValues:dict];
    }
    return self;
}

@end


