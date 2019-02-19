//
//  Playlist.m
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "Playlist.h"

@implementation PlaylistRelationships
@end

@implementation Playlist
@synthesize relationships = _relationships;

+(NSDictionary*)mj_replacedKeyFromPropertyName{
    return @{@"editorialNotes":@"description"};
}
@end
