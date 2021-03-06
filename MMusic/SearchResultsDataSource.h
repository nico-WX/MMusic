//
//  SearchResultsDataSource.h
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/20.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ResponseRoot;

NS_ASSUME_NONNULL_BEGIN

@protocol SearchResultsDataSourceDelegate <NSObject>

- (void)configureCell:(UITableViewCell*)cell object:(Resource*)resource;
@end

@interface SearchResultsDataSource : NSObject

- (void)searchTerm:(NSString*)term;

- (NSString*)titleAtSection:(NSUInteger)section;
- (ResponseRoot*)dataWithSection:(NSUInteger)section;
- (NSArray<Resource*>*)allResurceAtSection:(NSUInteger)section;
- (void)clearData;

- (instancetype)initWithTableView:(UITableView*)tableView
                   cellIdentifier:(NSString*)cellIdentifier
                sectionIdentifier:(NSString*)sectionIdentifier
                         delegate:(id<SearchResultsDataSourceDelegate>)delegate;
@end

NS_ASSUME_NONNULL_END
