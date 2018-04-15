//
//  Recommendation.m
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "Recommendation.h"
#import "Resource.h"
#import <MJExtension.h>

#pragma mark 实现推荐
@implementation Recommendation
+(NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"identifier":@"id"};
}

+(instancetype)instanceWithDict:(NSDictionary *)dict{
    return [[self alloc] initWithDict:dict];
}

-(instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super initWithDict:dict]) {
        [self mj_setKeyValues:dict];
    }
    return self;
}
@end

#pragma mark推荐属性
@implementation Attributes
+(instancetype)instanceWithDict:(NSDictionary *)dict{
    return [[self alloc] initWithDict:dict];
}
-(instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super initWithDict:dict]) {
        [self mj_setKeyValues:dict];
    }
    return self;
}
@end

#pragma mark 关联
@implementation Relationships
+(instancetype)instanceWithDict:(NSDictionary *)dict{
    return [[self alloc] initWithDict:dict];
}
-(instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super initWithDict:dict]) {
        [self mj_setKeyValues:dict];
    }
    return self;
}
@end

#pragma makr 关联非组类型 子集
@implementation Contents
+(NSDictionary *)mj_objectClassInArray{
    return @{@"data":@"Resource"};
}
+(instancetype)instanceWithDict:(NSDictionary *)dict{
    return [[self alloc] initWithDict:dict];
}
-(instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super initWithDict:dict]) {
        [self mj_setKeyValues:dict];
    }
    return self;
}
@end

#pragma mark 关联组类型 子集
@implementation Recommendations
+(NSDictionary *)mj_objectClassInArray{
    return @{@"data":@"Recommendation"};
}
+(instancetype)instanceWithDict:(NSDictionary *)dict{
    return [[self alloc] initWithDict:dict];
}
-(instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super initWithDict:dict]) {
        [self mj_setKeyValues:dict];
    }
    return  self;
}
@end
