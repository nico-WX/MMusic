//
//  ShowAllSearchResultsDataSource.h
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/24.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "DataSource.h"

@class ResponseRoot;
NS_ASSUME_NONNULL_BEGIN

@interface ShowAllSearchResultsDataSource : DataSource
//加载的数据
@property(nonatomic,readonly)NSArray<Resource*> *data;

- (instancetype)initWithView:(UICollectionView*)collectionView
                  identifier:(NSString*)identifier
                responseRoot:(ResponseRoot*)root
                    delegate:(id<DataSourceDelegate>)delegate;
@end

NS_ASSUME_NONNULL_END
