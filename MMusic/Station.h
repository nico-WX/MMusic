//
//  Station.h
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "Resource.h"
@class Artwork;
@class EditorialNotes;

@interface Station : Resource
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *url;

@property(nonatomic, strong) Artwork *artwork;
@property(nonatomic, strong) EditorialNotes *editorialNotes;

@property(nonatomic, strong) NSNumber *durationInMillis;
@property(nonatomic, strong) NSNumber *episodeNumber;
@property(nonatomic, strong) NSDictionary *playParams;

@property(nonatomic, assign) Boolean isLive;

@end
