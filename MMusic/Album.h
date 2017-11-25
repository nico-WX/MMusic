//
//  Album.h
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Artwork;
@class EditorialNotes;
@class PlayParameters;

@interface Album : NSObject

@property(nonatomic, copy) NSString *artistName;
@property(nonatomic, copy) NSString *contentRating;
@property(nonatomic, copy) NSString *copyright;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *recordLabel;
@property(nonatomic, copy) NSString *releaseDate;
@property(nonatomic, copy) NSString *url;

@property(nonatomic, strong) Artwork        *artwork;
@property(nonatomic, strong) EditorialNotes *editorialNotes;
@property(nonatomic, strong) PlayParameters *playParams;

@property(nonatomic, strong) NSArray<NSString*> *genreNames;

@property(nonatomic) Boolean isComplete;
@property(nonatomic) Boolean isSingle;
@property(nonatomic,assign) NSNumber *trackCount;

-(instancetype)initWithDict:(NSDictionary *) dict;
+(instancetype)albumWithDict:(NSDictionary*) dict;
@end
