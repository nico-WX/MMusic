//
//  ChartsData.h
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/23.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class Chart;
@interface ChartsData : NSObject
@property(nonatomic, assign) NSInteger count;   //排行榜节数据
- (Chart*)chartWithIndexPath:(NSIndexPath*)indexPath;
- (void)requestChartsWithCompletion:(void(^)(ChartsData *chartData))completion;

@end

NS_ASSUME_NONNULL_END
