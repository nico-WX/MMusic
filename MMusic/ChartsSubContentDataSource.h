//
//  ChartsSubContentDataSource.h
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/16.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "DataSource.h"

@class Chart;
NS_ASSUME_NONNULL_BEGIN


// cell 内部的集合视图数据源
@interface ChartsSubContentDataSource : DataSource

@property(nonatomic, strong, readonly)Chart *chart;

- (instancetype)initWithChart:(Chart*)chart
               collectionView:(UICollectionView*)collectionView
              reuseIdentifier:(NSString*)identifier
                     delegate:(id<DataSourceDelegate>)delegate;
@end

NS_ASSUME_NONNULL_END
