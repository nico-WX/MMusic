//
//  RecommendationDataSource.h
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/23.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class Resource;

//配置cell 协议
@protocol RecommendationDataSourceDelegate <NSObject>

- (void)configureCell:(UICollectionViewCell*)cell object:(Resource*)resource;
- (void)configureSupplementaryElement:(UICollectionReusableView*)reusableView object:(NSString*)title ;
@end

@interface RecommendationDataSource : NSObject<UICollectionViewDataSource>


//- (instancetype)initWithTableView:(UITableView*)tableView cellReuseIdentifier:(NSString*)identifier;
- (instancetype)initWithCollectionView:(UICollectionView*)collectionView
                        cellIdentifier:(NSString*)identifier
                     sectionIdentifier:(NSString*)sectionIdentifier
                              delegate:(id<RecommendationDataSourceDelegate>)delegate NS_DESIGNATED_INITIALIZER;

- (void)refreshDataWithCompletion:(void(^)(void))completion;
@end

NS_ASSUME_NONNULL_END
