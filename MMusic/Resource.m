//
//  Resource.m
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "Resource.h"

@implementation Resource
//替换关键字
+(NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"identifier":@"id"};
}
- (instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super initWithDict:dict]) {

        [self mj_setKeyValues:dict];

        //NSLog(@"attri =%@",self.attributes);
        if (![self isMemberOfClass:[Resource class]]) {
            //子类
            [self mj_setKeyValues:[dict valueForKey:JSONAttributesKey]];
        }
    }
    return self;
}
+(instancetype)instanceWithDict:(NSDictionary *)dict{
    return [[self alloc] initWithDict:dict];
}


// 通过Resource实例   实例化一个Resource子类(类似向下转换)
+(instancetype)instanceWithResource:(Resource *)resource{
    return [[self alloc] initWithResource:resource];
}
- (instancetype)initWithResource:(Resource *)resource{
    if ([self isMemberOfClass:[Resource class]]) {
        NSString *name = @"方法调用错误";
        NSString *reason = [NSString stringWithFormat:@"%s 方法只能在子类中调用",_cmd];
        @throw [NSException exceptionWithName:name reason:reason userInfo:nil];
        return nil;
    }else{
        if (self = [super init]) {
            //拷贝属性
            self.identifier = resource.identifier;
            self.href = resource.href;
            self.type = resource.type;
            self.attributes = resource.attributes;
            self.meta = resource.meta;
            //初始化
            [self mj_setKeyValues:resource.attributes];
        }
        return self;
    }
}
@end
