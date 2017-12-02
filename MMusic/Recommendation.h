//
//  Recommendation.h
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "MMObject.h"

@interface Recommendation : MMObject
/**推荐ID*/
@property(nonatomic, copy) NSString *identifier;
/**下一页*/
@property(nonatomic, copy) NSString *next;
/**推荐URL*/
@property(nonatomic, copy) NSString *href;
/**value always “personal-recommendation”*/
@property(nonatomic, copy) NSString *type;

/**相关的*/
@property(nonatomic, strong) NSDictionary *relationships;
/**推荐属性*/
@property(nonatomic, strong) NSDictionary *attributes;

@end
