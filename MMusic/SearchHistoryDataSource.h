//
//  SearchHistoryDataSource.h
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/20.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SearchHistoryDataSourceDelegate <NSObject>

- (void)configureCell:(UITableViewCell*)cell object:(NSString*)obj;

@end

@interface SearchHistoryDataSource : NSObject

- (instancetype)initWithTableView:(UITableView*)tableView
                       identifier:(NSString*)identifier
                         delegate:(id<SearchHistoryDataSourceDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
