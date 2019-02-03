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

@interface CuratorAttribute : MMObject

@property(nonatomic, strong) Artwork *artwork;
@property(nonatomic, strong) EditorialNotes *editorialNotes;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *url;

@end

@interface CuratorRelationship : Relationship

@end

@interface Curator : Resource
@property(nonatomic,strong)CuratorAttribute *attributes;
@property(nonatomic,strong)CuratorRelationship *relationships;

@end
