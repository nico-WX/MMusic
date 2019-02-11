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

//配置cell 协议
@protocol RecommendationDataSourceDelegate <NSObject>

- (void)configureCell:(UICollectionViewCell*)cell object:(Resource*)resource;
- (void)configureSupplementaryElement:(UICollectionReusableView*)reusableView object:(NSString*)title ;
@end

@interface RecommendationDataSource : DataSource

- (instancetype)initWithCollectionView:(UICollectionView*)collectionView
                        cellIdentifier:(NSString*)identifier
                     sectionIdentifier:(NSString* _Nullable)sectionIdentifier
                              delegate:(id<RecommendationDataSourceDelegate>)delegate;

- (Resource*)selectedResourceAtIndexPath:(NSIndexPath*)indexPath;
@end

NS_ASSUME_NONNULL_END
