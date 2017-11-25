//
//  Artwork.m
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "Artwork.h"
#import <MJExtension.h>

@implementation Artwork

-(instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super init]) {
        [self mj_setKeyValues:dict];
    }
    return self;
}
+(instancetype)artworkWithDict:(NSDictionary *)dict{
    return [[self alloc] initWithDict:dict];
}
@end
