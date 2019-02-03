//
//  Artist.m
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

/*@class EditorialNotes;*/

#import "Artist.h"
//#import <MJExtension.h>


@implementation Artist
@synthesize attributes = _attributes;
@synthesize relationships = _relationships;

@end

@implementation ArtistAttributes

+(NSDictionary *)mj_objectClassInArray{
    return @{@"genreNames":@"NSString"};
}

@end

@implementation ArtistRelationship
@end
