//
//  Song.m
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "Song.h"
#import "Artwork.h"
#import "EditorialNotes.h"
#import "PlayParameters.h"
#import "Preview.h"

#import <MJExtension.h>
#import <MediaPlayer/MediaPlayer.h>

@implementation Song

-(instancetype)initWithDict:(NSDictionary *)dict{
    if(self = [super initWithDict:dict]){
        [self mj_setKeyValues:dict];
    }
    return self;
}

+(instancetype)instanceWithDict:(NSDictionary *)dict{
    return [[self alloc] initWithDict:dict];
}
+(NSDictionary *)mj_objectClassInArray{
    return @{@"previews":@"Preview",@"genreNames":@"NSString"};
}


-(BOOL)isEqualToNowPlayItem:(MPMediaItem *)mediaItem{
    NSString *nowPlaySongID = mediaItem.playbackStoreID;
    NSString *cellSongID = [self.playParams objectForKey:@"id"];
    return [nowPlaySongID isEqualToString:cellSongID];
}

@end
