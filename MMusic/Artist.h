//
//  Artist.h
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "Resource.h"

@class EditorialNotes;


@interface ArtistRelationship : Relationship
@end

@interface Artist : Resource
@property(nonatomic, strong) NSArray<NSString*> *genreNames;
@property(nonatomic, strong) EditorialNotes *editorialNotes;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *url;

@property(nonatomic,strong) ArtistRelationship *relationships;

@end
