//
//  Chart.m
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "Chart.h"
#import "Resource.h"

#import <MJExtension.h>

@implementation Chart
+(NSDictionary *)mj_objectClassInArray{
    return @{@"data":@"Resource"};
}
-(instancetype)initWithDict:(NSDictionary *)dict{
    if (self =[super init]) {
        [self mj_setKeyValues:dict];
    }
    return self;
}
+(instancetype)chartWithDict:(NSDictionary *)dict{
    return [[self alloc] initWithDict:dict];
}
@end
