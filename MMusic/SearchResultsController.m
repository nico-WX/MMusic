//
//  SearchResultsController.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/20.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "SearchResultsController.h"

#import "SearchHintsDataSource.h"
#import "SearchResultsDataSource.h"
#import "Resource.h"


@interface SearchResultsController ()<UISearchBarDelegate,UITableViewDelegate,SearchHintsDataSourceDelegate,SearchResultsDataSourceDelegate>
@property(nonatomic,strong) UISearchBar *searchBar;
@property(nonatomic,strong) UITableView *hintsTableView;

@property(nonatomic,strong) SearchHintsDataSource *hintsDataSource;
@property(nonatomic,strong) SearchResultsDataSource *resultsDataSource;
@end

static NSString *const hintsIdentifier = @"hints cell identifier";
static NSString *const resultsIdentifier = @"search results identifier";
static NSString *const resultsSectionIdentifier = @"search secetion identifier";

@implementation SearchResultsController

@synthesize searchResultsView = _searchResultsView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    _hintsDataSource = [[SearchHintsDataSource alloc] initWithTableView:self.hintsTableView
                                                             identifier:hintsIdentifier
                                                               delegate:self];
    _resultsDataSource = [[SearchResultsDataSource alloc] initWithTableView:self.searchResultsView
                                                             cellIdentifier:resultsIdentifier
                                                          sectionIdentifier:resultsSectionIdentifier
                                                                   delegate:self];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [_searchResultsView setFrame:self.view.bounds];
    [_hintsTableView setFrame:self.view.bounds];
}


#pragma mark - getter / setter
-(UITableView *)hintsTableView{
    if (!_hintsTableView) {
        _hintsTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_hintsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:hintsIdentifier];
        [_hintsTableView setDelegate:self];
    }
    return _hintsTableView;
}
- (UITableView *)searchResultsView{
    if (!_searchResultsView) {
        _searchResultsView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_searchResultsView registerClass:[UITableViewCell class] forCellReuseIdentifier:resultsIdentifier];
        //代理在主搜索视图中
    }
    return _searchResultsView;
}

// set
- (void)setSearchBar:(UISearchBar *)searchBar{
    if (_searchBar != searchBar) {
        _searchBar = searchBar;
        [_searchBar setDelegate:self];
    }
}

#pragma mark  - ********************Delegate

#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (tableView == self.hintsTableView) {
        NSString *term = cell.textLabel.text;
        [self.searchBar setText:term];
        [self.searchBar.delegate searchBarSearchButtonClicked:self.searchBar];
    }
}

#pragma mark - SearchHintsDataSourceDelegate
- (void)configureCell:(UITableViewCell *)cell hintsString:(NSString *)term{
    [cell.textLabel setText:term];
}

#pragma mark - SearchResultsDataSourceDelegate;
-(void)configureCell:(UITableViewCell *)cell object:(Resource *)resource{
    [cell.textLabel setText:[resource.attributes valueForKey:@"name"]];
}

#pragma mark - UISearchResultsUpdating
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    self.searchBar = searchController.searchBar;
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self.searchResultsView removeFromSuperview];
    [self.view addSubview:self.hintsTableView];
    [self.hintsDataSource searchHintsWithTerm:searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.hintsTableView removeFromSuperview];
    [self.view addSubview:self.searchResultsView];
    [self.resultsDataSource searchTerm:searchBar.text];
    [searchBar resignFirstResponder];
}

@end