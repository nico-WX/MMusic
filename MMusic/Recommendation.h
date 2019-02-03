//
//  Recommendation.h
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "Resource.h"


@interface RecommendationAttributes : MMObject
@property(nonatomic,assign) BOOL isGroupRecommendation;
@property(nonatomic,strong) NSDate *nextUpdateDate;
@property(nonatomic,copy) NSString *reason;
@property(nonatomic,copy) NSString *title;
@property(nonatomic,strong) NSArray<NSString*> *resourceTypes;
@end

@interface RecommendationRelationships : Relationship

@end

@interface Recommendation : Resource
@property(nonatomic,strong)RecommendationAttributes *attributes;
@property(nonatomic,strong)RecommendationRelationships *relationships;

@end


