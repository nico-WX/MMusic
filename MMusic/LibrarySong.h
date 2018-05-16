//
//  LibrarySong.h
//  MMusic
//
//  Created by Magician on 2018/5/14.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import "MMObject.h"
@class Artwork;

@interface LibrarySong : MMObject

@property(nonatomic, strong) NSString *albumName;
@property(nonatomic, strong) NSString *artistName;
@property(nonatomic, strong) NSString *contentRating;
@property(nonatomic, strong) NSString *name;

@property(nonatomic, strong) Artwork *artwork;

@property(nonatomic, assign) NSInteger discNumber;
@property(nonatomic, assign) NSInteger trackNumber;

@property(nonatomic, strong) NSNumber *durationInMillis;
@property(nonatomic, strong) NSDictionary *playParams;

@end
