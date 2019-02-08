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

//子类方便调用
+(instancetype)instanceWithResource:(Resource *)resource{
    return [[self alloc] initWithResource:resource];
}
-(instancetype)initWithResource:(Resource *)resource{
    //非子类调用, 抛出异常

    if ([self isMemberOfClass:Resource.class]) {
        @throw
        [NSException exceptionWithName:NSInvalidSendPortException
                                reason:[NSString stringWithFormat:@"You must invoke %@ in a subclass init", NSStringFromSelector(_cmd)]
                              userInfo:nil];
        return nil;
    }else{
        return [self initWithDict:(resource.attributes)];
    }
}
@end
