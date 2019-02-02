//
//  LibraryDataSource.h
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/27.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MPMediaQuery;
@class MPMediaItem;

NS_ASSUME_NONNULL_BEGIN

@protocol LibraryDataSourceDelegate <NSObject>

- (void)configureCell:(UICollectionViewCell*)cell object:(MPMediaItem*)item;

@end

@interface LibraryDataSource : NSObject

- (instancetype)initWithCollectionView:(UICollectionView*)collectionView
                            identifier:(NSString*)identifier
                            mediaQuery:(MPMediaQuery*)query
                              delegate:(id<LibraryDataSourceDelegate>) delegate;

@end

NS_ASSUME_NONNULL_END
