//
//  ResourceDetailDataSource.h
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/22.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "DataSource.h"


NS_ASSUME_NONNULL_BEGIN


@interface ResourceDetailDataSource : DataSource

@property(nonatomic,strong,readonly) NSArray<Song*> *songLists;

- (instancetype)initWithTableView:(UITableView*)tableView
                       identifier:(NSString*)identifier
                         resource:(Resource*)resource
                         delegate:(id<DataSourceDelegate>)delegate;
@end

NS_ASSUME_NONNULL_END
