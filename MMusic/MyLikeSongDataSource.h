//
//  MyLikeSongDataSource.h
//  MMusic
//
//  Created by 🐙怪兽 on 2019/2/4.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SongManageObject.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MyLikeSongDataSourceDelegate <NSObject>

- (void)configureTableCell:(UITableViewCell*)cell songManageObject:(SongManageObject*)song;
@end

@interface MyLikeSongDataSource : NSObject
@property(nonatomic,strong,readonly)NSArray<SongManageObject *> *songList;

- (instancetype)initWithTableVoew:(UITableView*)tableView identifier:(NSString*)identifier delegate:(id<MyLikeSongDataSourceDelegate>) delegate;


@end

NS_ASSUME_NONNULL_END
