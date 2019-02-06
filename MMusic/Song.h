//
//  Song.h
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "Resource.h"

@class Artwork;
@class EditorialNotes;
@class Preview;
@class MPMediaItem;
@class SongManageObject;


@interface SongAttributes : MMObject

@property(nonatomic, copy) NSString *artistName;
@property(nonatomic, copy) NSString *composerName;
@property(nonatomic, copy) NSString *contentRating;
@property(nonatomic, copy) NSString *isrc;
@property(nonatomic, copy) NSString *movementName;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *releaseDate;
@property(nonatomic, copy) NSString *url;
@property(nonatomic, copy) NSString *workName;

@property(nonatomic, strong) Artwork *artwork;
@property(nonatomic, strong) EditorialNotes *editorialNotes;
@property(nonatomic, strong) NSDictionary *playParams;

@property(nonatomic, strong) NSNumber *durationInMillis;
@property(nonatomic, strong) NSArray<NSString*> *genreNames;
@property(nonatomic, strong) NSArray<Preview*> *previews;

@property(nonatomic, assign) int discNumber;
@property(nonatomic, assign) int movementCount;
@property(nonatomic, assign) int movementNumber;
@property(nonatomic, assign) int trackNumber;

@end

@interface SongRelationships : Relationship
@end

@interface Song : Resource

@property(nonatomic,strong)SongAttributes *attributes;
@property(nonatomic,strong)SongRelationships *relationships;

/**
 比较两个对象的 playbackStoreID
 @param mediaItem 媒体对象
 @return 是否为相同的歌曲
 */
-(BOOL) isEqualToMediaItem:(MPMediaItem*) mediaItem;

+ (instancetype)instanceWithSongManageObject:(SongManageObject*)songManageObject;
- (instancetype)initWithSongManageObject:(SongManageObject*)songManageObject;
@end
