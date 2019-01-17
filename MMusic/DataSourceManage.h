//
//  DataSourceManage.h
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/17.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN



// TableView

@protocol TableViewDataSourceDelegate <NSObject>
- (void)configureTableViewCell:(UITableViewCell *)cell resourceObject:(id)object;
@end


@protocol TableViewDataSource <NSObject>
- (instancetype)initWithTableView:(UITableView *)tableView
                  reuseIdentifier:(NSString *)identifier
                         delegate:(id<TableViewDataSourceDelegate>)delegate;

- (instancetype)initWithTableView:(UITableView *)tableView
                  reuseIdentifier:(NSString *)identifier
                         delegate:(id<TableViewDataSourceDelegate>)delegate
                        configure:(void(^)(UITableViewCell *cell,id object))configureCell;
@end


// CollectionView

@protocol CollectionViewDataSourceDelegate <NSObject>
- (void)configureTableViewCell:(UITableViewCell *)cell resourceObject:(id)object;

@end

@protocol CollectionViewDataSource <NSObject>
- (instancetype)initWithCollectionView:(UICollectionView *)collectionView
                       reuseIdentifier:(NSString *)identifier
                              delegate:(id<CollectionViewDataSourceDelegate>)delegate;

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView
                       reuseIdentifier:(NSString *)identifier
                              delegate:(id<CollectionViewDataSourceDelegate>)delegate
                             configure:(void(^)(UICollectionViewCell *cell, id object))configureCell;
@end



NS_ASSUME_NONNULL_END
