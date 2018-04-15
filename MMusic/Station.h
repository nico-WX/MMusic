//
//  Station.h
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "MMObject.h"
@class Artwork;
@class EditorialNotes;

@interface Station : MMObject
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *url;

@property(nonatomic, strong) Artwork *artwork;
@property(nonatomic, strong) EditorialNotes *editorialNotes;

@property(nonatomic, strong) NSNumber *durationInMillis;
@property(nonatomic, strong) NSNumber *episodeNumber;

@property(nonatomic, assign) Boolean isLive;

@end
