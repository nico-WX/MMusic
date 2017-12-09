//
//  Song.h
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

@interface Song : MMObject
/**艺人名称*/
@property(nonatomic, copy) NSString *artistName;
/**作家*/
@property(nonatomic, copy) NSString *composerName;
/**内容评级*/
@property(nonatomic, copy) NSString *contentRating;
/**国际标准录音编码*/
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
