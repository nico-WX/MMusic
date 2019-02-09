//
//  SearchResultsController.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/20.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "SearchResultsController.h"
#import "SearchResultsCell.h"
#import "SearchResultsSectionView.h"

#import "SearchHintsDataSource.h"
#import "SearchResultsDataSource.h"
#import "Resource.h"


@interface SearchResultsController ()<UISearchBarDelegate,UITableViewDelegate,SearchHintsDataSourceDelegate,SearchResultsDataSourceDelegate>

@property(nonatomic,strong) UISearchBar *searchBar;
@property(nonatomic,strong) UITableView *hintsTableView;

@property(nonatomic,strong) SearchHintsDataSource *hintsDataSource;
@property(nonatomic,strong) SearchResultsDataSource *resultsDataSource;

@property(nonatomic,strong) id showObserver;
@property(nonatomic,strong) id hideObserver;
@end

static NSString *const hintsIdentifier = @"hints cell identifier";
static NSString *const resultsIdentifier = @"search results identifier";
static NSString *const resultsSectionIdentifier = @"search secetion identifier";

@implementation SearchResultsController

@synthesize searchResultsView = _searchResultsView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    //  视图在SearchBar delegate 方法中触发添加



    _hintsDataSource = [[SearchHintsDataSource alloc] initWithTableView:self.hintsTableView
                                                             identifier:hintsIdentifier
                                                               delegate:self];

    _resultsDataSource = [[SearchResultsDataSource alloc] initWithTableView:self.searchResultsView
                                                             cellIdentifier:resultsIdentifier
                                                          sectionIdentifier:resultsSectionIdentifier
                                                                   delegate:self];

    //键盘通知,修改frame
    __weak typeof(self) weakSelf = self;
    _showObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardDidShowNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        CGRect keyboardFrame = [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGRect frame = [UIScreen mainScreen].bounds;
        frame.size.height -= keyboardFrame.size.height;
        weakSelf.view.frame = frame;
    }];
    _hideObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardDidHideNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        CGRect frame = [UIScreen mainScreen].bounds;
        //frame.size.height -= 47;
        weakSelf.view.frame = frame;
    }];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];

    [self.searchResultsView setFrame:self.view.bounds];
    [self.hintsTableView setFrame:self.view.bounds];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:_showObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:_hideObserver];
    _showObserver = nil;
    _hideObserver = nil;
}

#pragma mark - getter
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
        // 问题: 使用self.view.bounds 初始化时, 为什么数据源中的tableView 为null , 且调用cell 出栈函数
        _searchResultsView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_searchResultsView registerClass:[SearchResultsCell class] forCellReuseIdentifier:resultsIdentifier];
        [_searchResultsView setRowHeight:80];
        //代理在主搜索视图中
    }
    return _searchResultsView;
}


#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //选中hints cell 执行搜索
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
    if ([cell isKindOfClass:[SearchResultsCell class]]) {
        [((SearchResultsCell*)cell) setResource:resource];
    }
}

#pragma mark - UISearchResultsUpdating
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    self.searchBar = searchController.searchBar;
    self.searchBar.delegate = self;
}


#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self.view addSubview:self.hintsTableView];
    [self.hintsDataSource searchHintsWithTerm:searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.view addSubview:self.searchResultsView];
    [self.resultsDataSource searchTerm:searchBar.text];
    [searchBar resignFirstResponder];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
//    [self.hintsDataSource clearData];
//    [self.resultsDataSource clearData];
}

@end
