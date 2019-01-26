//
//  ShowAllSearchResultsDataSource.h
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/24.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ResponseRoot;
NS_ASSUME_NONNULL_BEGIN

@protocol ShowAllSearchResultsDataSourceDelegate <NSObject>

- (void)configureCollectionCell:(UICollectionViewCell*)cell object:(Resource*)resource;

@end

@interface ShowAllSearchResultsDataSource : NSObject

- (instancetype)initWithView:(UICollectionView*)collectionView
                  identifier:(NSString*)identifier
                responseRoot:(ResponseRoot*)root
                    delegate:(id<ShowAllSearchResultsDataSourceDelegate>)delegate;
@end

NS_ASSUME_NONNULL_END
