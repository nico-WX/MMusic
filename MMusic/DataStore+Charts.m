//
//  DataStore+Charts.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/8.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import "DataStore+Charts.h"
#import "Chart.h"

@implementation DataStore (Charts)
- (void)requestAllCharts:(AllChartsDataCallBak)callBack{

    NSMutableArray<Chart*> *chartArray = [NSMutableArray array];

    [MusicKit.new.catalog chartsByType:ChartsAll callBack:^(NSDictionary *json, NSHTTPURLResponse *response) {
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

        //返回数据
        if (callBack) callBack(chartArray);

        //没有本地MV数据, 请求香港地区数据
        if (![json valueForKey:@"music-videos"]){
            [self requestHongKongMVDataWithCompletion:^(Chart *chart) {
                [chartArray addObject:chart];
                //添加新数据, 重新返回
                callBack(chartArray);
            }];
        }
    }];
}

//内地无MV 排行数据, 请求香港地区
- (void)requestHongKongMVDataWithCompletion:(void(^)(Chart* chart))callBack {

    NSString *path = @"https://api.music.apple.com/v1/catalog/hk/charts?types=music-videos";
    NSURLRequest *request = [self createRequestWithURLString:path setupUserToken:NO];

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


@end
