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

        //父类属性
        self.url = songManageObject.url;
        self.identifier = songManageObject.identifier;
    }
    return self;
}


-(BOOL)isEqualToMediaItem:(MPMediaItem *)mediaItem{
    return [mediaItem.playbackStoreID isEqualToString:self.identifier];
}

@end
