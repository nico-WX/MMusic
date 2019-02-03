//
//  AppleCurator.h
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "Resource.h"
@class Artwork;
@class EditorialNotes;

/**Apple发布的*/

@interface AppleCuratorAttributes : MMObject
@property(nonatomic, strong) Artwork *artwork;
@property(nonatomic, strong) EditorialNotes *editorialNotes;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *url;
@end

@interface AppleCuratorRelationships : Relationship

@end

@interface AppleCurator : Resource
@property(nonatomic,strong) AppleCuratorAttributes *attributes;
@property(nonatomic,strong) AppleCuratorRelationships *relationships;
@end
