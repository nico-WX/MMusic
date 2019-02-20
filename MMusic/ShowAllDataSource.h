//
//  ShowAllDataSource.h
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/23.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "DataSource.h"

@class Chart;

NS_ASSUME_NONNULL_BEGIN

@interface ShowAllDataSource : DataSource
@property(nonatomic,strong,readonly) Chart *chart;

- (instancetype)initWithCollectionView:(UICollectionView*)collectionView
                       reuseIdentifier:(NSString*)identifier
                                 chart:(Chart*)chart
                              delegate:(id<DataSourceDelegate>)delegate;
@end

NS_ASSUME_NONNULL_END
