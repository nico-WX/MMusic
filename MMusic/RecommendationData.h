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

/**每一节数据count*/
- (NSInteger)numberOfItemsInSection:(NSInteger)section;
/**节count*/
- (NSInteger)numberOfSection;

/**对应下标数据*/
- (Resource*)dataWithIndexPath:(NSIndexPath*)indexPath;
/**节title*/
- (NSString*)titleWithSection:(NSInteger)section;


/**
  默认推荐数据请求方法, 数据取回后会调用回调

 @param completion 完成回调
 */
-(void)defaultRecommendataionWithCompletion:(void (^)(BOOL success))completion;

@end

NS_ASSUME_NONNULL_END
