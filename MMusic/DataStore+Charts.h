//
//  DataStore+Charts.h
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/8.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import "DataStore.h"

NS_ASSUME_NONNULL_BEGIN

@class Chart;
typedef void(^AllChartsDataCallBak)(NSArray<Chart*>* chartArray);
@interface DataStore (Charts)
- (void)requestAllCharts:(AllChartsDataCallBak)callBack;
@end

NS_ASSUME_NONNULL_END
