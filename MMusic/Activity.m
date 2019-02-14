//
//  Activity.m
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//


#import "Activity.h"

#import "Artwork.h"
#import "Playlist.h"
#import "EditorialNotes.h"


@implementation Activity
@synthesize attributes = _attributes;
@synthesize relationships = _relationships;

- (instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super initWithDict:dict]) {
        [self mj_setKeyValues:[dict valueForKey:JSONAttributesKey]];
    }
    return self;
}
@end

@implementation ActivityRelationships
@end





