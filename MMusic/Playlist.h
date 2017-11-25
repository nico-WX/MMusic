//
//  Playlist.h
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Artwork;
@class EditorialNotes;
@class PlayParameters;

typedef enum : NSUInteger {
    user_shared,//user-shared
    editorial,
    external,
    personal_mix,//personal-mix
} PlaylistType;

@interface Playlist : NSObject
@property(nonatomic, copy) NSString *curatorName;
@property(nonatomic, copy) NSString *url;

@property(nonatomic, strong) Artwork *artwork;
@property(nonatomic, strong) EditorialNotes *desc; //description
@property(nonatomic, strong) PlayParameters *playParams;

@property(nonatomic, assign) PlaylistType playlistType;

-(instancetype)initWithDict:(NSDictionary*) dict;
+(instancetype)playlistWithDict:(NSDictionary*) dict;
@end

