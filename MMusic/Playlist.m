//
//  Playlist.m
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "Playlist.h"
#import <MJExtension.h>

@implementation Playlist

+(NSDictionary*)mj_replacedKeyFromPropertyName{
    return @{@"desc":@"description"};
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
