//
//  ChartsSubContentDataSource.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/16.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "ChartsSubContentDataSource.h"
#import "Chart.h"


@implementation ChartsSubContentDataSource

- (instancetype)initWithChart:(Chart*)chart
               collectionView:(UICollectionView *)collectionView
              reuseIdentifier:(NSString *)identifier
                     delegate:(id<DataSourceDelegate>)delegate{
    if (self = [super initWithCollectionView:collectionView identifier:identifier sectionIdentifier:nil delegate:delegate]) {
        _chart = chart;
    }
    return self;
}

#pragma mark - dataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _chart.data.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.identifier forIndexPath:indexPath];
    Resource *resource = [self.chart.data objectAtIndex:indexPath.row];
    [self configureCell:cell item:resource atIndexPath:indexPath];
    return cell;
}

@end
