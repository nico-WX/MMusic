//
//  Song.m
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "Song.h"
#import <MediaPlayer/MediaPlayer.h>


@implementation SongAttributes

+(NSDictionary *)mj_objectClassInArray{
    return @{@"previews":@"Preview",@"genreNames":@"NSString"};
}

- (instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super initWithDict:dict]) {
        
    }
    return self;
}

@end

@implementation SongRelationships
@end


@implementation Song
@synthesize attributes = _attributes;
@synthesize relationships = _relationships;

- (instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super initWithDict:dict]) {
        _attributes = [SongAttributes instanceWithDict:dict];
        _relationships = [SongRelationships instanceWithDict:dict];
    }
    return self;
}

-(BOOL)isEqualToMediaItem:(MPMediaItem *)mediaItem{
    NSString *storeID = mediaItem.playbackStoreID;
    NSString *songID = [self.attributes.playParams objectForKey:@"id"];
    return [storeID isEqualToString:songID];
}

@end
