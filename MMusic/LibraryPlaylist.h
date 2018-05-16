//
//  LibraryPlaylist.h
//  MMusic
//
//  Created by Magician on 2018/5/14.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import "MMObject.h"

@class Artwork;
@class EditorialNotes;

@interface LibraryPlaylist : MMObject

@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) Artwork *artwork;
@property(nonatomic, strong) EditorialNotes *desc; //description
@property(nonatomic, strong) NSDictionary *playParams;
@property(nonatomic, assign) Boolean canDelete;
@property(nonatomic, assign) Boolean canEdit;

@end
