//
//  ChartsSubContentDataSource.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/16.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "ChartsSubContentDataSource.h"
#import "Chart.h"

@interface ChartsSubContentDataSource ()<UICollectionViewDataSource>
@property(nonatomic, weak)UICollectionView *collectionView;
@property(nonatomic, copy)NSString *identifier;
@property(nonatomic, weak)id<ChartsSubContentDataSourceDelegate> delegate;

@end

@implementation ChartsSubContentDataSource

- (instancetype)initWithChart:(Chart*)chart
               collectionView:(UICollectionView *)collectionView
              reuseIdentifier:(NSString *)identifier
                     delegate:(id<ChartsSubContentDataSourceDelegate>)delegate{
    if (self = [super init]) {
        _collectionView = collectionView;
        [collectionView setDataSource:self];
        _identifier = identifier;
        _delegate= delegate;
        _chart = chart;
    }
    return self;
}

#pragma mark - dataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _chart.data.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_identifier forIndexPath:indexPath];
    if ([_delegate respondsToSelector:@selector(configureCell:object:)]) {
        [_delegate configureCell:cell object:[_chart.data objectAtIndex:indexPath.row]];
    }
    return cell;
}

@end
