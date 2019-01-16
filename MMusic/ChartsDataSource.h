//
//  ChartsDataSource.h
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/16.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Chart;

NS_ASSUME_NONNULL_BEGIN

@protocol ChartsDataSourceDelegate <NSObject>

- (void)configureCell:(UITableViewCell*)cell object:(Chart*)chart;

@end

@interface ChartsDataSource : NSObject

- (instancetype)initWithTableView:(UITableView*)tableView
                  reuseIdentifier:(NSString*)identifier
                         delegate:(id<ChartsDataSourceDelegate>)delegate;
@end

NS_ASSUME_NONNULL_END
