//
//  SearchViewController.m
//  MMusic
//
//  Copyright © 2018年 com.😈. All rights reserved.

#import <Masonry.h>
#import <MJRefresh.h>

#import "SearchViewController.h"
#import "SearchResultsController.h"

#import "SearchHistoryDataSource.h"

//实现代理分类
@interface SearchViewController (Delegate)<UITableViewDelegate,SearchHistoryDataSourceDelegate>
@end

@interface SearchViewController ()
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) UISearchController *searchController;
@property(nonatomic, strong) SearchHistoryDataSource *searchHistoryDataSource;

@end

static NSString *const identifier = @"cell identifier";
@implementation SearchViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;

    [self.view addSubview:self.tableView];
    //[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    self.searchHistoryDataSource = [[SearchHistoryDataSource alloc] initWithTableView:self.tableView
                                                                           identifier:identifier
                                                                             delegate:self];

    //[self.navigationController.navigationBar setPrefersLargeTitles:YES];
    //[self.navigationItem setSearchController:self.searchController];
    //[self.navigationItem setHidesSearchBarWhenScrolling:NO];

    [self.tableView setTableHeaderView:self.searchController.searchBar];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];

    [_tableView setFrame:self.view.bounds];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - getter / setter
-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:identifier];
        [_tableView setDelegate:self];
    }
    return _tableView;
}

- (UISearchController *)searchController{
    if (!_searchController) {
        SearchResultsController *vc = [[SearchResultsController alloc] init];
        [vc.searchResultsView setDelegate:self]; //获取选中的结果,入栈显示

        _searchController = [[UISearchController alloc] initWithSearchResultsController:vc];
        [_searchController setSearchResultsUpdater:vc];
    }
    return _searchController;
}

@end


@implementation SearchViewController (Delegate)

#pragma mark SearchHistoryDataSourceDelegate
-(void)configureCell:(UITableViewCell *)cell object:(nonnull NSString *)obj{
    [cell.textLabel setText:obj];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if (tableView == self.tableView) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSString *term = cell.textLabel.text;
        UISearchBar *searchBar = self.searchController.searchBar;
        [searchBar setText:term];
        [searchBar.delegate searchBarSearchButtonClicked:searchBar];
    }else{
        NSLog(@"res");
    
    }

}

@end
