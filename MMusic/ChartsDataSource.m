//
//  ChartsDataSource.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/16.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "NSURLRequest+CreateURLRequest.h"

#import "ChartsDataSource.h"
#import "Chart.h"

@interface ChartsDataSource ()<UITableViewDataSource>
@property(nonatomic, weak)id<ChartsDataSourceDelegate> delegate;
@property(nonatomic, weak)UITableView *tableView;
@property(nonatomic, copy)NSString *identifier;

//data
@property(nonatomic, strong) NSArray<Chart*> *charts;
@end

@implementation ChartsDataSource

- (instancetype)initWithTableView:(UITableView *)tableView
                  reuseIdentifier:(NSString *)identifier
                         delegate:(id<ChartsDataSourceDelegate>)delegate{
    if (self = [super init]) {
        _tableView = tableView;
        [tableView setDataSource:self];
        _identifier = identifier;
        _delegate = delegate;
        [self requestChartsWithCompletion:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
    }
    return self;
}


- (void)requestChartsWithCompletion:(void (^)(void))completion{

    [MusicKit.new.catalog chartsByType:ChartsAll callBack:^(NSDictionary *json, NSHTTPURLResponse *response) {
        NSMutableArray<Chart*> *chartArray = [NSMutableArray array];
        json = [json valueForKey:@"results"];
        if (json) {
            [json enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {

                //每一个Key 对应数组,如{@"albums":[{Chart},]}
                NSArray *tempArray = (NSArray*)obj;
                [tempArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    Chart *chart = [Chart instanceWithDict:(NSDictionary*)obj];
                    [chartArray addObject:chart];
                }];
            }];
        }

        self.charts = chartArray;
        completion();

//        //没有本地MV数据, 请求香港地区数据
//        if (![json valueForKey:@"music-videos"]){
//            [self requestHongKongMVDataWithCompletion:^(Chart *chart) {
//                [chartArray addObject:chart];
//                self.charts = chartArray;
//                if (completion) completion();
//            }];
//        }else{
//            self.charts = chartArray;
//            if (completion) completion();
//        }
    }];
}

//内地无MV 排行数据, 请求香港地区
- (void)requestHongKongMVDataWithCompletion:(void(^)(Chart* chart))callBack {

    NSString *path = @"https://api.music.apple.com/v1/catalog/hk/charts?types=music-videos";
    NSURLRequest *request = [NSURLRequest createRequestWithURLString:path setupUserToken:NO];

    [self dataTaskWithRequest:request handler:^(NSDictionary *json, NSHTTPURLResponse *response) {
        json = [json valueForKey:@"results"];

        __block Chart *hkMVChart;
        if (json) {
            [json enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                NSArray *tempArray = (NSArray*)obj;
                [tempArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    hkMVChart = [Chart instanceWithDict:(NSDictionary*)obj];
                }];
            }];
        }
        if (callBack) callBack(hkMVChart);
    }];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[self charts] count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.identifier];
    [self.delegate configureCell:cell object:[self.charts objectAtIndex:indexPath.row]];
    return cell;
}

@end
