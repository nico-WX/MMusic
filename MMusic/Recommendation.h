//
//  Recommendation.h
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "Resource.h"
#import "MMObject.h"
@class Resource;
@class Contents;
@class Recommendations;
@class Recommendation;

/**推荐 的Attributes 属性*/
@interface Attributes : MMObject
@property(nonatomic, assign) BOOL isGroupRecommendation;
@property(nonatomic, strong) NSDictionary *title;
@property(nonatomic, strong) NSDictionary *reason;
@property(nonatomic, strong) NSArray<NSString*> *resourceTypes;
@property(nonatomic, copy)   NSString *nextUpdateDate;
@end

/**推荐的关联属性*/
@interface Relationships : MMObject
@property(nonatomic, strong) Contents *contents;
@property(nonatomic, strong) Recommendations *recommendations;
@end

/**关联非组类型内容*/
@interface Contents : MMObject
@property(nonatomic, strong) NSArray<Resource*> *data;
@end
/**关联组类型内容 主内容数组内包含着推荐集合*/
@interface Recommendations : MMObject
@property(nonatomic, strong) NSArray<Recommendation*> *data;
@end

/**推荐*/
@interface Recommendation : MMObject
@property(nonatomic, copy) NSString *identifier;
@property(nonatomic, copy) NSString *next;
@property(nonatomic, copy) NSString *href;
/**value always “personal-recommendation”*/
@property(nonatomic, copy) NSString *type;
@property(nonatomic, strong) Relationships *relationships;
@property(nonatomic, strong) Attributes *attributes;

@end
