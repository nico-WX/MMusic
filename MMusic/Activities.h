//
//  Activities.h
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "MMObject.h"

@class Artwork;
@class EditorialNotes;

/**活动*/
@interface Activities : MMObject
//属性
/**活动海报*/
@property(nonatomic, strong) Artwork *artwork;
/**在iTunes Store上的注释*/
@property(nonatomic, strong) EditorialNotes *editorialNotes;
/**本地活动名称*/
@property(nonatomic, copy) NSString *name;
/**iTuens Store URL*/
@property(nonatomic, copy) NSString *url;
@end

