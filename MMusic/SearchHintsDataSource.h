//
//  SearchHintsDataSource.h
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/20.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SearchHintsDataSourceDelegate <NSObject>

- (void)configureCell:(UITableViewCell*)cell hintsString:(NSString*)term;

@end

@interface SearchHintsDataSource : NSObject


- (instancetype)initWithTableView:(UITableView*)tableView
                       identifier:(NSString*)identifier
                         delegate:(id<SearchHintsDataSourceDelegate>)delegate;

- (void)searchHintsWithTerm:(NSString*)term;
@end

NS_ASSUME_NONNULL_END
