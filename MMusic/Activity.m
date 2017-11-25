//
//  Activity.m
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "Activity.h"
#import "Playlist.h"
#import "EditorialNotes.h"
#import "Artwork.h"

#import <MJExtension.h>

@implementation Activity

+(NSDictionary *)mj_objectClassInArray{
    return @{@"playlists":@"Playlist"};
}
+(instancetype)activityWithDict:(NSDictionary *)dict{
    return [[self alloc] initWithDict:dict];
}
-(instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super init]) {
        [self mj_setKeyValues:dict];
    }
    return self;
}
@end
