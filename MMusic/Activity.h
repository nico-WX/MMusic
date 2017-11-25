//
//  Activity.h
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Artwork;
@class EditorialNotes;
@class Playlist;

@interface Activity : NSObject

@property(nonatomic, strong) Artwork        *artwork;
@property(nonatomic, strong) EditorialNotes *editorialNotes;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *url;
@property(nonatomic, strong) NSArray<Playlist*> *playlists;

-(instancetype)initWithDict:(NSDictionary*) dict;
+(instancetype)activityWithDict:(NSDictionary*) dict;
@end
