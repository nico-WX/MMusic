//
//  Chart.m
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "Chart.h"
#import <MJExtension.h>
#import "Resource.h"

@implementation Chart
//-(instancetype)initWithDict:(NSDictionary *)dict{
//    if (self =[super initWithDict:dict]) {
//        [self mj_setKeyValues:dict];
//    }
//    return self;
//}
//+(instancetype)instanceWithDict:(NSDictionary *)dict{
//    return [[self alloc] initWithDict:dict];
//}
+(NSDictionary *)mj_objectClassInArray{
    return @{@"data":@"Resource"};
}
@end
