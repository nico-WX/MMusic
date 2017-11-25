//
//  ResponseRoot.m
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "ResponseRoot.h"
#import "Resource.h"
#import <MJExtension.h>

@implementation ResponseRoot

+(NSDictionary *)mj_objectClassInArray{
    return @{@"data":@"Resource"};
}

+(instancetype)responseRootWithDict:(NSDictionary *)dict{
    return [[self alloc] initWithDict:dict];
}
-(instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super init]) {
        [self mj_setKeyValues:dict];
    }
    return self;
}


@end
