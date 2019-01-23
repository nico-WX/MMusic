//
//  ChartsSubContentDataSource.h
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/16.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Chart;
NS_ASSUME_NONNULL_BEGIN

@protocol ChartsSubContentDataSourceDelegate <NSObject>

- (void)configureCell:(UICollectionViewCell*)cell object:(Resource*)resource;
@end

@interface ChartsSubContentDataSource : NSObject
@property(nonatomic, strong, readonly)Chart *chart;

- (instancetype)initWithChart:(Chart*)chart
               collectionView:(UICollectionView*)collectionView
              reuseIdentifier:(NSString*)identifier
                     delegate:(id<ChartsSubContentDataSourceDelegate>)delegate;
@end

NS_ASSUME_NONNULL_END
