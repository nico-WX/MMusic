//
//  Recommendation.m
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "Recommendation.h"



@implementation Recommendation

@synthesize relationships = _relationships;

- (instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super initWithDict:dict]) {
        [self mj_setKeyValues:[dict valueForKey:JSONAttributesKey]];

//        if (self.isGroupRecommendation) {
//            _relationships = [RecommendationRelationships instanceWithDict:[dict valueForKeyPath:@"relationships.recommendations"]];
//        }else{
//            _relationships = [RecommendationRelationships instanceWithDict:[dict valueForKeyPath:@"relationships.contents"]];
//        }
    }
    return self;
}

@end




