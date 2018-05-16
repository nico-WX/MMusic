//
//  LibraryAlbum.h
//  MMusic
//
//  Created by Magician on 2018/5/14.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import "MMObject.h"

@class Artwork;
@interface LibraryAlbum : MMObject

@property(nonatomic, strong) NSString *artistName;
@property(nonatomic, strong) NSString *contentRating;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) Artwork *artwork;
@property(nonatomic, strong) NSDictionary *playParams;
@property(nonatomic, strong) NSNumber *trackCount;

@end
