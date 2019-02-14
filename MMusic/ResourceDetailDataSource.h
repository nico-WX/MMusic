//
//  ResourceDetailDataSource.h
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/22.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@protocol ResourceDetailDataSourceDelegate <NSObject>

- (void)configureCell:(UITableViewCell*)cell object:(Song*)song atIndex:(NSUInteger)index;
//- (void)configureCell:(UITableViewCell*)cell object:(Song*)obj;

@end
@interface ResourceDetailDataSource : NSObject
@property(nonatomic,strong,readonly) NSArray<Song*> *songLists;

- (instancetype)initWithTableView:(UITableView*)tableView
                       identifier:(NSString*)identifier
                         resource:(Resource*)resource
                         delegate:(id<ResourceDetailDataSourceDelegate>)delegate;
@end

NS_ASSUME_NONNULL_END
