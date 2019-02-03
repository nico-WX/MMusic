//
//  Artist.h
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "Resource.h"

@class EditorialNotes;

@interface ArtistAttributes : MMObject
@property(nonatomic, strong) NSArray<NSString*> *genreNames;
@property(nonatomic, strong) EditorialNotes *editorialNotes;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *url;
@end

@interface ArtistRelationship : Relationship

@end

@interface Artist : Resource

@property(nonatomic,strong) ArtistAttributes *attributes;
@property(nonatomic,strong) ArtistRelationship *relationships;

@end
