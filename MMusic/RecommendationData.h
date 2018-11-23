//
//  RecommendationData.h
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/23.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class Resource;

@interface RecommendationData : NSObject
@property(nonatomic, assign, readonly)NSInteger sectionCount;    //
- (NSInteger)numberOfSection:(NSInteger)section;
- (Resource*)dataWithIndexPath:(NSIndexPath*)indexPath;
- (NSString*)titleWithSection:(NSInteger)section;


/**
 在该方法内部请求数据,数据取回后会调用回调

 @param completion 推荐数据模型实例 与方法接收者同一个对象;
 */
- (void)defaultRecommendataionWithCompletion:(void(^)(RecommendationData *recommendataion))completion;
@end

NS_ASSUME_NONNULL_END
