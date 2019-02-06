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


@implementation SongAttributes

+(NSDictionary *)mj_objectClassInArray{
    return @{@"previews":@"Preview",@"genreNames":@"NSString"};
}
@end

@implementation SongRelationships
@end


@implementation Song

@synthesize attributes = _attributes;
@synthesize relationships = _relationships;

+(instancetype)instanceWithSongManageObject:(SongManageObject *)songManageObject{
    return [[self alloc] initWithSongManageObject:songManageObject];
}
- (instancetype)initWithSongManageObject:(SongManageObject *)songManageObject{
    if (self = [super init]) {
        self.identifier = songManageObject.identifier;

        _attributes = [[SongAttributes alloc] init];
        _attributes.name = songManageObject.name;
        _attributes.artwork =  [Artwork instanceWithDict:songManageObject.artwork];
        _attributes.artistName = songManageObject.artistName;
        _attributes.playParams = songManageObject.playParams;
    }
    return self;
}


- (instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super initWithDict:dict]) {
        _attributes = [SongAttributes instanceWithDict:[dict valueForKey:@"attributes"]];
        _relationships = [SongRelationships instanceWithDict:[dict valueForKey:@"relationships"]];
    }
    return self;
}

-(BOOL)isEqualToMediaItem:(MPMediaItem *)mediaItem{
    return [mediaItem.playbackStoreID isEqualToString:self.identifier];
}

@end
