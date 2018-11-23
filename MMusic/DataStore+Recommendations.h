//
//  DataStore+Recommendations.h
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/8.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import "DataStore.h"

NS_ASSUME_NONNULL_BEGIN
@class Resource;

//回调块定义
typedef void(^defaultRecommendationBlock)(NSArray<NSDictionary<NSString*,NSArray<Resource*>*>*>* array);
@interface DataStore (Recommendations)
@property(nonatomic, assign,readonly)NSUInteger count;
@property(nonatomic, assign,readonly)NSUInteger sectionCount;

- (void)recommendationSectionTitleAtIndexPath:(NSIndexPath*)indexPath;
- (void)recommendationResouceAtIndexPath:(NSIndexPath*)indexPath completion:(void(^)(Resource*))dataCallBack;

- (void)requestDefaultRecommendationWithCompletion:(defaultRecommendationBlock)callBack;
@end

NS_ASSUME_NONNULL_END
