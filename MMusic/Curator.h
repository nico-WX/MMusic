//
//  Curator.h
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "Resource.h"

@class Artwork;
@class EditorialNotes;


@interface CuratorRelationship : Relationship
@end

@interface Curator : Resource
@property(nonatomic, strong) Artwork *artwork;
@property(nonatomic, strong) EditorialNotes *editorialNotes;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *url;

@property(nonatomic,strong)CuratorRelationship *relationships;

@end
