//
//  ChartsViewController.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/15.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "ChartsViewController.h"
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
    self.dataSource =[[ChartsDataSource alloc] initWithTableView:self.tableView reuseIdentifier:identifier delegate:self];
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



#pragma mark - delegate
-(void)configureCell:(UITableViewCell *)cell object:(Chart *)chart{
    if ([cell isKindOfClass:[ChartsCell class]]) {
        ChartsCell *chartsCell = (ChartsCell*)cell;
        [chartsCell setChart:chart];
        [chartsCell.collectionView setDelegate:self];
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 300;
}
@end
