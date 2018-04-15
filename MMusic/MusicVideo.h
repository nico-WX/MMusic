//
//  MusicVideo.h
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "MMObject.h"

@class Artwork;
@class EditorialNotes;
@class PlayParameters;
@class Preview;

@interface MusicVideo : MMObject
@property(nonatomic, copy) NSString *artistName;
@property(nonatomic, copy) NSString *contentRating;
@property(nonatomic, copy) NSString *isrc;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *releaseDate;
@property(nonatomic, copy) NSString *url;
@property(nonatomic, copy) NSString *videoSubType;

@property(nonatomic, strong) Artwork *artwork;
@property(nonatomic, strong) EditorialNotes *editorialNotes;
@property(nonatomic, strong) NSDictionary *playParams;

@property(nonatomic, strong) NSArray<NSString*> *genreNames;
@property(nonatomic, strong) NSArray<Preview*> *previews;

@property(nonatomic, strong) NSNumber *durationInMillis;
@property(nonatomic, strong) NSNumber *trackNumber;

@end
