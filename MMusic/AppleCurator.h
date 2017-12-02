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
/**Apple的海报*/
@property(nonatomic, strong) Artwork *artwork;
@property(nonatomic, strong) EditorialNotes *editorialNotes;
/**本地名称*/
@property(nonatomic, copy) NSString *name;
/**具体URL*/
@property(nonatomic, copy) NSString *url;

@end
