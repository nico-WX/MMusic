//
//  EditorialNotes.m
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "EditorialNotes.h"
#import <MJExtension.h>

@implementation EditorialNotes

+(NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"shortNotes":@"short"};
}
+(instancetype)instanceWithDict:(NSDictionary *)dict{
    return [[self alloc] initWithDict:dict];
}
-(instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super init]) {
        [self mj_setKeyValues:dict];
    }
    return  self;
}

@end
