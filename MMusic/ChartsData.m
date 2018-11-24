//
//  ChartsData.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/23.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import "ChartsData.h"
#import "Chart.h"

@interface ChartsData ()
@property(nonatomic, strong) NSArray<Chart*> *chartList;

@end

@implementation ChartsData

- (NSInteger)count{
    return self.chartList.count;
}

- (Chart *)chartWithIndexPath:(NSIndexPath *)indexPath{
    return [self.chartList objectAtIndex:indexPath.row];
}

- (void)requestChartsWithCompletion:(void (^)(ChartsData * _Nonnull))completion{

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

        //没有本地MV数据, 请求香港地区数据
        if (![json valueForKey:@"music-videos"]){
            [self requestHongKongMVDataWithCompletion:^(Chart *chart) {
                [chartArray addObject:chart];
                self.chartList = chartArray;
                if (completion) completion(self);
            }];
        }else{
            self.chartList = chartArray;
            if (completion) completion(self);
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
