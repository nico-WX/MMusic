//
//  Song.m
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "Song.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation Song

+(NSDictionary *)mj_objectClassInArray{
    return @{@"previews":@"Preview",@"genreNames":@"NSString"};
}

-(BOOL)isEqualToMediaItem:(MPMediaItem *)mediaItem{
    NSString *storeID = mediaItem.playbackStoreID;
    NSString *songID = [self.playParams objectForKey:@"id"];
    return [storeID isEqualToString:songID];
}

@end
