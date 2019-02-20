//
//  ShowAllDataSource.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/23.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "NSURLRequest+Extension.h"
#import "ShowAllDataSource.h"
#import "Chart.h"


@interface ShowAllDataSource ()<UICollectionViewDataSource>
@end

@implementation ShowAllDataSource
- (instancetype)initWithCollectionView:(UICollectionView *)collectionView
                       reuseIdentifier:(NSString *)identifier
                                 chart:(nonnull Chart *)chart
                              delegate:(id<DataSourceDelegate>)delegate{
    if (self = [super initWithCollectionView:collectionView identifier:identifier sectionIdentifier:nil delegate:delegate]) {
        _chart = chart;

        [self loadAllResourceWithChart:chart complection:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [collectionView reloadData];
            });
        }];
    }
    return self;
}

- (void)loadAllResourceWithChart:(Chart*)chart complection:(void(^)(void))complection{
    [self loadNextPage:chart.next complection:complection];
}
- (void)loadNextPage:(NSString*)nextURL complection:(void(^)(void)) complection{
    NSURLRequest *request = [NSURLRequest createRequestWithHref:nextURL];
    [self dataTaskWithRequest:request handler:^(NSDictionary *json, NSHTTPURLResponse *response) {
        json = [json valueForKey:@"results"];
        if (json) {
            __block Chart *newChart;
            [json enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                newChart = [Chart instanceWithDict:[((NSArray*)obj) firstObject]];
            }];

            //旧数据和新数据添加到新数组, 再赋值给data
            NSMutableArray<Resource*> *temp = [NSMutableArray arrayWithArray:self.chart.data];
            [temp addObjectsFromArray:newChart.data];

            self.chart.data = temp;
            self.chart.next = newChart.next;
            // 递归请求所有的数据,
            if (self.chart.next) {
                [self loadNextPage:self.chart.next complection:complection];
            }else{
                complection();
            }
        }
    }];

}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _chart.data.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.identifier forIndexPath:indexPath];
    Resource *resource = [self.chart.data objectAtIndex:indexPath.row];
    [self configureCell:cell item:resource atIndexPath:indexPath];
    return cell;
}

@end
