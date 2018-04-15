//
//  Relationship.m
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "Relationship.h"
#import <MJExtension.h>

@implementation Relationship
-(instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super init]) {
        [self mj_setKeyValues:dict];
    }
    return self;
}
+(instancetype)instanceWithDict:(NSDictionary *)dict{
    return [[self alloc] initWithDict:dict];
}
@end
