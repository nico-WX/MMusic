//
//  SearchHintsDataSource.h
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/20.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "DataSource.h"

NS_ASSUME_NONNULL_BEGIN

@interface SearchHintsDataSource : DataSource

- (void)searchHintsWithTerm:(NSString*)term;

@end

NS_ASSUME_NONNULL_END
