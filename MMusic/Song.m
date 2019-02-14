//
//  Song.m
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "Song.h"
#import "SongManageObject.h"
#import "Artwork.h"

#import <MediaPlayer/MediaPlayer.h>

@implementation SongRelationships
@end

@implementation Song

@synthesize relationships = _relationships;

+(NSDictionary *)mj_objectClassInArray{
    return @{@"previews":@"Preview",@"genreNames":@"NSString"};
}
+(instancetype)instanceWithSongManageObject:(SongManageObject *)songManageObject{
    return [[self alloc] initWithSongManageObject:songManageObject];
}
- (instancetype)initWithSongManageObject:(SongManageObject *)songManageObject{
    if (self = [super init]) {

        _name = songManageObject.name;
        _artwork =  [Artwork instanceWithDict:songManageObject.artwork];
        _artistName = songManageObject.artistName;
        _playParams = songManageObject.playParams;
        _durationInMillis = songManageObject.durationInMillis;

        self.url = songManageObject.url;
        self.identifier = songManageObject.identifier;
    }
    return self;
}

- (instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super initWithDict:dict]) {
        [self mj_setKeyValues:[dict valueForKey:JSONAttributesKey]];
    }
    return self;
}

-(BOOL)isEqualToMediaItem:(MPMediaItem *)mediaItem{
    return [mediaItem.playbackStoreID isEqualToString:self.identifier];
}

+(instancetype)instanceWithResource:(Resource *)resource{
    return [[self alloc] initWithResource:resource];
}
- (instancetype)initWithResource:(Resource *)resource{
    if (self = [super init]) {
        [self mj_setKeyValues:resource.attributes];
        self.identifier = resource.identifier;
        self.href = resource.href;
        self.type = resource.type;
        self.attributes = resource.attributes;
        self.meta = resource.meta;
        //self.relationships = resource.relationships;

    }
    return self;
}
@end
