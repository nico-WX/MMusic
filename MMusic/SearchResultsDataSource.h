//
//  SearchResultsDataSource.h
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/20.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "DataSource.h"
@class ResponseRoot;

NS_ASSUME_NONNULL_BEGIN


@interface SearchResultsDataSource : DataSource
/**搜索字段*/
- (void)searchTerm:(NSString*)term;

- (NSString*)titleAtSection:(NSUInteger)section;
- (ResponseRoot*)dataWithSection:(NSUInteger)section;
- (NSArray<Resource*>*)allResurceAtSection:(NSUInteger)section;


@end

NS_ASSUME_NONNULL_END
