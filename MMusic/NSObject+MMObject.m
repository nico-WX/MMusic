//
//  NSObject+MMObject.m
//  MMusic
//
//  Created by Magician on 2018/4/9.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import "NSObject+MMObject.h"

@implementation NSObject (MMObject)
-(instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [self init]) {
    }
    return self;
}
+(instancetype)instanceWithDict:(NSDictionary *)dict{
    return [[self alloc]initWithDict:dict];
}
@end
