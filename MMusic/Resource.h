//
//  Resource.h
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "MMObject.h"
#import "Relationship.h"


static NSString *const JSONAttributesKey = @"attributes";
static NSString *const JSONSongTypeKey = @"songs";
static NSString *const JSONMusicVideosTypeKey = @"music-videos";

@interface Resource : MMObject

@property(nonatomic, copy) NSString *identifier;  // json key => id
@property(nonatomic, copy) NSString *type;
@property(nonatomic, copy) NSString *href;
@property(nonatomic, strong) NSDictionary *attributes;  //子类属性
@property(nonatomic, strong) NSDictionary *meta;
@property(nonatomic, strong) Relationship *relationships;



+ (instancetype)instanceWithResource:(Resource*)resource;
- (instancetype)initWithResource:(Resource*)resource;
@end
