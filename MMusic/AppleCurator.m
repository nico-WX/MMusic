//
//  AppleCurator.m
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

/*
 @class Artwork;
 @class EditorialNotes;
 */

#import "AppleCurator.h"
#import "Artwork.h"
#import "EditorialNotes.h"
#import <MJExtension.h>

@implementation AppleCurator
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
