//
//  Playlist.h
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "MMObject.h"

@class Artwork;
@class EditorialNotes;
@class PlayParameters;

@interface Playlist : MMObject
@property(nonatomic, copy) NSString *curatorName;
@property(nonatomic, copy) NSString *url;
@property(nonatomic, copy) NSString *playlistType;
@property(nonatomic, copy) NSString *lastModifiedDate;
@property(nonatomic, copy) NSString *name;

@property(nonatomic, strong) Artwork *artwork;
@property(nonatomic, strong) EditorialNotes *editorialNotes; //description
@property(nonatomic, strong) NSDictionary *playParams;

@end


