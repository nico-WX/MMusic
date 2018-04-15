//
//  AppleCurator.h
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "MMObject.h"

@class Artwork;
@class EditorialNotes;

/**Apple发布的*/
@interface AppleCurator : MMObject

@property(nonatomic, strong) Artwork *artwork;
@property(nonatomic, strong) EditorialNotes *editorialNotes;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *url;

@end
