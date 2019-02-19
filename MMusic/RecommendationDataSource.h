//
//  RecommendationDataSource.h
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/23.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import "DataSource.h"

NS_ASSUME_NONNULL_BEGIN
@class Resource;


@protocol RecommendationDataSourceDelegate <DataSourceDelegate>

@optional
//- (void)configureCell:(UICollectionViewCell*)cell object:(Resource*)resource;
- (void)configureSupplementaryElement:(UICollectionReusableView*)reusableView object:(NSString*)title ;
@end

@interface RecommendationDataSource : DataSource

- (Resource*)selectedResourceAtIndexPath:(NSIndexPath*)indexPath;
@end

NS_ASSUME_NONNULL_END
