//
//  LibrarySong.m
//  MMusic
//
//  Created by Magician on 2018/5/14.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import "LibrarySong.h"
#import "Artwork.h"

@implementation LibrarySong
-(instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super initWithDict:dict]) {
        [self mj_setKeyValues:dict];
    }
    return self;
}
@end
