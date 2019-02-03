//
//  Recommendation.m
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "Recommendation.h"

@implementation RecommendationAttributes
- (instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super initWithDict:dict]) {

        [self mj_setKeyValues:dict];
        _title = [dict valueForKeyPath:@"title.stringForDisplay"];
    }
    return self;
}
@end

@implementation RecommendationRelationships
- (instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super initWithDict:dict]) {
        [self mj_setKeyValues:dict];
    }
    return self;
}
@end

@implementation Recommendation
@synthesize attributes = _attributes;
@synthesize relationships = _relationships;

- (instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super initWithDict:dict]) {

        _attributes = [RecommendationAttributes instanceWithDict:[dict valueForKey:@"attributes"]];
        if (self.attributes.isGroupRecommendation) {
            _relationships = [RecommendationRelationships instanceWithDict:[dict valueForKeyPath:@"relationships.recommendations"]];
        }else{
            _relationships = [RecommendationRelationships instanceWithDict:[dict valueForKeyPath:@"relationships.contents"]];
        }


    }
    return self;
}

@end




