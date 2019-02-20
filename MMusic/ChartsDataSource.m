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
@property(nonatomic,strong)JGProgressHUD *hud;
//data
@property(nonatomic, strong) NSArray<Chart*> *charts;

@end

@implementation ChartsDataSource

- (instancetype)initWithTableView:(UITableView *)tableViwe identifier:(NSString *)identifier sectionIdentifier:(NSString *)sectionIdentifier delegate:(id<DataSourceDelegate>)delegate{
    if (self = [super initWithTableView:tableViwe identifier:identifier sectionIdentifier:sectionIdentifier delegate:delegate]) {

        [self loadChartsForTableView:tableViwe];
    }
    return self;
}

- (void)loadChartsForTableView:(UITableView*)tableView{

    [self.hud showInView:tableView animated:YES];

    [MusicKit.new.catalog allChartsWithCompletion:^(NSDictionary *json, NSHTTPURLResponse *response) {
        //回调,停止刷新
        [tableView.mj_header endRefreshing];
        if (response.statusCode == 200) {
            NSMutableArray<Chart*> *chartArray = [NSMutableArray array];

            json = [json valueForKey:@"results"];
            [json enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                //每一个Key 对应数组,如{@"albums":[{Chart},]}
                NSArray *tempArray = (NSArray*)obj;
                [tempArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    Chart *chart = [Chart instanceWithDict:(NSDictionary*)obj];
                    [chartArray addObject:chart];
                }];
            }];

            //解析完成
            self.charts = chartArray;
            [self.hud dismissAnimated:YES];
            [self.hud removeFromSuperview];
            [tableView reloadData];

        }else{

            NSString *text = [NSString stringWithFormat:@"加载失败,请刷新.[code: %ld]",response.statusCode];
            self.hud.indicatorView = nil;
            [self.hud.textLabel setText:text];
            if (!tableView.mj_header) {
                tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
                    self.hud.textLabel.text = @"loading...";
                    [self loadChartsForTableView:tableView];
                }];
            }
        }
    }];

}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[self charts] count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.identifier];
    Chart *chart = [self.charts objectAtIndex:indexPath.row];
    [self configureCell:cell item:chart atIndexPath:indexPath];
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
