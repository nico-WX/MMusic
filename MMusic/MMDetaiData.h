//
//  MMDetaiData.h
//  MMusic
//
//  Created by 🐙怪兽 on 2018/12/26.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DetailDataSourceDelegate <NSObject>

- (void)configureCell:(UITableViewCell*)cell object:(Song*)song withIndex:(NSUInteger)index;
@end

@interface MMDetaiData : NSObject
- (instancetype)initWithTableView:(UITableView*)tableView resource:(Resource*)resource cellIdentifier:(NSString*)cellIdentifier delegate:(id<DetailDataSourceDelegate>)delegate;
@end

NS_ASSUME_NONNULL_END
