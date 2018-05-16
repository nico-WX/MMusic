//
//  LibraryPlaylist.m
//  MMusic
//
//  Created by Magician on 2018/5/14.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import "LibraryPlaylist.h"
#import "Artwork.h"
#import "EditorialNotes.h"

@implementation LibraryPlaylist

-(instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super initWithDict:dict]) {
        [self mj_setKeyValues:dict];
    }
    return self;
}
+(instancetype)instanceWithDict:(NSDictionary *)dict{
    return [[self alloc] initWithDict:dict];
}
+(NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"desc":@"description"};
}

@end
