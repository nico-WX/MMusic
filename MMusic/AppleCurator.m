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

@implementation AppleCurator

@synthesize relationships = _relationships;

- (instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super initWithDict:dict]) {
        [self mj_setKeyValues:[dict valueForKey:JSONAttributesKey]];
    }
    return self;
}

@end


