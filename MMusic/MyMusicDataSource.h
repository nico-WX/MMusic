//
//  MyMusicDataSource.h
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/27.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@protocol MyMusicDataSourceDelegate <NSObject>

- (void)configureCell:(UITableViewCell*)cell object:(UIViewController*)vc;

@end

@interface MyMusicDataSource : NSObject
- (instancetype)initWithView:(UITableView*)tableView
                  identifier:(NSString*)identifier
                    delegate:(id<MyMusicDataSourceDelegate>)delegate;
@end

NS_ASSUME_NONNULL_END
