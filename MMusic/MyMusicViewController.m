//
//  MyMusicViewController.m
//  MMusic
//
//  Created by Magician on 2017/11/8.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import <Masonry.h>

#import "MyMusicViewController.h"
#import "MyMusicTableCell.h"
#import "MyMusicDataSource.h"
#import "UITableView+Extension.h"


@interface MyMusicViewController ()<UITableViewDelegate,MyMusicDataSourceDelegate>
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)MyMusicDataSource *dataSource;
@end

static NSString *identifier = @"cell identifier";
@implementation MyMusicViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    [self.navigationItem setTitle:@"资料库"];
    [self.navigationController.navigationBar setPrefersLargeTitles:YES];

    [self.view addSubview:self.tableView];
    self.dataSource = [[MyMusicDataSource alloc] initWithView:_tableView identifier:identifier delegate:self];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];

    [_tableView setFrame:self.view.bounds];
}

#pragma mark - setter/getter
-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView setBackgroundColor:UIColor.whiteColor];
        [_tableView registerClass:[MyMusicTableCell class] forCellReuseIdentifier:identifier];
        [_tableView setRowHeight:50];
        [_tableView setDelegate:self];
        [_tableView hiddenSurplusSeparator];
    }
    return _tableView;
}


#pragma mark MyMusicDataSourceDelegate
- (void)configureCell:(UITableViewCell *)cell object:(nonnull UIViewController *)vc{
    [((MyMusicTableCell*)cell) setViewController:vc];
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MyMusicTableCell *cell = (MyMusicTableCell*)[tableView cellForRowAtIndexPath:indexPath];
    [self.navigationController pushViewController:cell.viewController animated:YES];
}
@end
