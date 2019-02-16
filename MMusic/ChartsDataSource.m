//
//  ChartsDataSource.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/16.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import <JGProgressHUD.h>
#import <MJRefresh.h>
#import "ChartsDataSource.h"
#import "Chart.h"

@interface ChartsDataSource ()<UITableViewDataSource>
@property(nonatomic, weak)id<ChartsDataSourceDelegate> delegate;
@property(nonatomic, weak)UITableView *tableView;
@property(nonatomic, copy)NSString *identifier;
@property(nonatomic,strong)JGProgressHUD *hud;
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

        //加载数据
        [self loadChartsForTableView:tableView];
    }
    return self;
}
- (void)loadChartsForTableView:(UITableView*)tableView{
    [self.hud showInView:tableView animated:YES];


    [MusicKit.new.catalog chartsByType:ChartsAll callBack:^(NSDictionary *json, NSHTTPURLResponse *response) {

        if (response.statusCode == 200) {

        }else{

            NSString *text
            mainDispatch(^{
                NSString *text = [NSString stringWithFormat:@"加载h失败,请刷新. /[code: %ld/]",res];
                [self.hud.textLabel setText:[NSString stringWithFormat:@"加载失败,请刷新.[code: %ld]",response]];
            });
        }

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

    }];


//    [self.hud showInView:tableView animated:YES];
//    [self requestChartsWithCompletion:^(NSArray<Chart *> *chartsArray) {
//        [tableView.mj_header endRefreshing];
//
//        NSLog(@"array =%@",chartsArray);
//        if (chartsArray.count > 0) {
//            [self.hud dismissAnimated:YES];
//            [self.hud removeFromSuperview];
//
//            self.charts = chartsArray;
//            [tableView reloadData];
//        }else{
//            [self.hud setIndicatorView:nil];
//            [self.hud.textLabel setText:@"加载失败,请刷新![]"];
//
//            if (!tableView.mj_header) {
//                MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
//
//                    [self.hud.textLabel setText:@"loading..."];
//                    JGProgressHUDIndicatorView *indicator = [JGProgressHUDIndeterminateIndicatorView new];
//                    [indicator setUpForHUDStyle:self.hud.style vibrancyEnabled:YES];
//                    [self.hud setIndicatorView:indicator];
//
//                    [self loadChartsForTableView:tableView];
//                }];
//
//
//                [tableView setMj_header:header];
//            }
//        }
//    }];
}

- (void)requestChartsWithCompletion:(void(^)(NSArray<Chart*> *chartsArray))completion{

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
        mainDispatch(^{
            completion(chartArray);
        });
    }];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[self charts] count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.identifier];
    if ([_delegate respondsToSelector:@selector(configureCell:object:)]) {
        [_delegate configureCell:cell object:[self.charts objectAtIndex:indexPath.row]];
    }
    return cell;
}


- (JGProgressHUD *)hud{
    if (!_hud) {
        _hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleExtraLight];
        _hud.textLabel.text = @"loading...";
    }
    return _hud;
}

@end
