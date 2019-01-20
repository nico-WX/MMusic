//
//  MMSearchMainViewController.m
//  MMusic
//
//  Copyright © 2018年 com.😈. All rights reserved.

#import <Masonry.h>
#import <MJRefresh.h>

#import "MMSearchMainViewController.h"
#import "MMSearchViewController.h"
#import "MMSearchViewControllerAnimation.h"
#import "MMSearchResultsViewController.h"
#import "MMTabBarController.h"

#import "SearchResultsController.h"
#import "SearchHistoryDataSource.h"


@interface MMSearchMainViewController ()<UITableViewDelegate,MMSearchViewControllerDelegate,UIViewControllerTransitioningDelegate,SearchHistoryDataSourceDelegate>
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) UISearchController *searchController;
@property(nonatomic, strong) SearchHistoryDataSource *searchHistoryDataSource;

@end

static NSString *const identifier = @"cell identifier";
@implementation MMSearchMainViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;

    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:identifier];
    [self.tableView setDelegate:self];
    [self.view addSubview:self.tableView];

    self.tableView.tableHeaderView = self.searchController.searchBar;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    self.searchHistoryDataSource = [[SearchHistoryDataSource alloc] initWithTableView:self.tableView
                                                                           identifier:identifier
                                                                             delegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



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
        //[self.searchController.searchBar setText:term];
        //[self.searchController.searchBar becomeFirstResponder];
    }else{
        NSLog(@"resTable");
    }


}

#pragma mark - getter / setter
- (UISearchController *)searchController{
    if (!_searchController) {
        SearchResultsController *vc = [[SearchResultsController alloc] init];
        _searchController = [[UISearchController alloc] initWithSearchResultsController:vc];
        [_searchController setSearchResultsUpdater:vc];
        [_searchController setDelegate:vc];
    }
    return _searchController;
}

@end
