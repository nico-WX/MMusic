//
//  ChartsViewController.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/15.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "ChartsViewController.h"
#import "ChartsSubContentCell.h"
#import "MMDetailViewController.h"
#import "ChartsCell.h"
#import "ChartsDataSource.h"

@interface ChartsViewController ()<UITableViewDelegate,ChartsDataSourceDelegate,UICollectionViewDelegate>
@property(nonatomic, strong)UITableView *tableView;
@property(nonatomic, strong)ChartsDataSource *dataSource;

@end

static NSString *const identifier = @"cell reuseIdentifier";
@implementation ChartsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.tableView];
    _dataSource =[[ChartsDataSource alloc] initWithTableView:_tableView reuseIdentifier:identifier delegate:self];
}


#pragma mark - getter
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [_tableView registerClass:[ChartsCell class] forCellReuseIdentifier:identifier];
        [_tableView setDelegate:self];
    }
    return _tableView;
}

#pragma mark - ChartsDataSourceDelegate
-(void)configureCell:(UITableViewCell *)cell object:(Chart *)chart{
    if ([cell isKindOfClass:[ChartsCell class]]) {
        ChartsCell *chartsCell = (ChartsCell*)cell;
        [chartsCell setChart:chart];
        //tableViewCell 中的集合视图代理设置为self, 获取选中的数据, 入栈新的控制器;
        [chartsCell.collectionView setDelegate:self];
    }
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 300;
}

#pragma mark - UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:[ChartsSubContentCell class]]) {
        Resource *resource = [((ChartsSubContentCell*)cell) resource];
        MMDetailViewController *detail = [[MMDetailViewController alloc] initWithResource:resource];
        [self.navigationController pushViewController:detail animated:YES];
    }
}
@end
