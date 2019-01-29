//
//  SearchViewController.m
//  MMusic
//
//  Copyright © 2018年 com.😈. All rights reserved.

#import <Masonry.h>
#import <MJRefresh.h>

#import "SearchViewController.h"

#import "SearchResultsController.h"
#import "SearchResultsSectionView.h"
#import "SearchResultsCell.h"

#import "ResourceDetailViewController.h"
#import "ShowAllSearchResultsViewController.h"

#import "SearchResultsDataSource.h"
#import "SearchHistoryDataSource.h"
#import "Resource.h"
#import "Song.h"

#import "MPMusicPlayerController+ResourcePlaying.h"

//分割代理方法
@interface SearchViewController (Delegate)<UITableViewDelegate,SearchHistoryDataSourceDelegate>
@end

@interface SearchViewController ()
/**搜索历史*/
@property(nonatomic, strong) UITableView *searchHistoryView;
@property(nonatomic, strong) UISearchController *searchController;
@property(nonatomic, strong) SearchHistoryDataSource *searchHistoryDataSource;

@end

static NSString *const identifier = @"cell identifier";
@implementation SearchViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;

    [self.view addSubview:self.searchHistoryView];
    //[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    self.searchHistoryDataSource = [[SearchHistoryDataSource alloc] initWithTableView:self.searchHistoryView
                                                                           identifier:identifier
                                                                             delegate:self];

    [self setDefinesPresentationContext:YES]; //当前环境呈现
    [self.navigationController.navigationBar setPrefersLargeTitles:YES];
    [self.navigationItem setSearchController:self.searchController];
    [self.navigationItem setHidesSearchBarWhenScrolling:NO];

    //[self.tableView setTableHeaderView:self.searchController.searchBar];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];

    [_searchHistoryView setFrame:self.view.bounds];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - getter / setter
-(UITableView *)searchHistoryView{
    if (!_searchHistoryView) {
        _searchHistoryView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_searchHistoryView registerClass:[UITableViewCell class] forCellReuseIdentifier:identifier];
        [_searchHistoryView setDelegate:self];
    }
    return _searchHistoryView;
}

- (UISearchController *)searchController{
    if (!_searchController) {
        SearchResultsController *vc = [[SearchResultsController alloc] init];
        [vc.searchResultsView setDelegate:self]; //选中时 push入栈导航控制器;

        _searchController = [[UISearchController alloc] initWithSearchResultsController:vc];
        [_searchController setSearchResultsUpdater:vc];
        //[_searchController.searchBar setAutocorrectionType:UITextAutocorrectionTypeNo];
        [_searchController setDimsBackgroundDuringPresentation:NO];
    }
    return _searchController;
}

@end


@implementation SearchViewController (Delegate)

#pragma mark - SearchHistoryDataSourceDelegate
-(void)configureCell:(UITableViewCell *)cell object:(nonnull NSString *)obj{
    [cell.textLabel setText:obj];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    if (tableView == self.searchHistoryView) {
        NSString *term = cell.textLabel.text;
        UISearchBar *searchBar = self.searchController.searchBar;
        [searchBar setText:term];
        [searchBar becomeFirstResponder];
        [searchBar.delegate searchBarSearchButtonClicked:searchBar];
    }else{

        if ([cell isKindOfClass:[SearchResultsCell class]]) {
            Resource *res = ((SearchResultsCell*)cell).resource;

            if ([res.type isEqualToString:@"songs"]) {
                NSArray<Resource*> *resources = [((SearchResultsDataSource*)tableView.dataSource) allResurceAtSection:indexPath.section];

                NSMutableArray<Song*> *songs = [NSMutableArray array];
                for (Resource *song in resources) {
                    [songs addObject:[Song instanceWithResource:song]];
                }
                [MainPlayer playSongs:songs startIndex:indexPath.row];
                
            }else{
                ResourceDetailViewController *detail = [[ResourceDetailViewController alloc] initWithResource:res];
                //详细视图不显示大的导航栏
                [detail.navigationItem setLargeTitleDisplayMode:UINavigationItemLargeTitleDisplayModeNever];
                [self.navigationController pushViewController:detail animated:YES];
            }
        }
    }
}

//搜索 结果分节
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (tableView != self.searchHistoryView) {
        return 60;
    }
    return 0;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (tableView != self.searchHistoryView) {
        SearchResultsSectionView *view = [[SearchResultsSectionView alloc] init];
        [view.showMoreButton handleControlEvent:UIControlEventTouchUpInside withBlock:^{
            if ([tableView.dataSource isKindOfClass:[SearchResultsDataSource class]]) {
                ResponseRoot *root = [((SearchResultsDataSource*)tableView.dataSource) dataWithSection:section];
                ShowAllSearchResultsViewController *allVC = [[ShowAllSearchResultsViewController alloc] initWithResponseRoot:root];
                [self.navigationController pushViewController:allVC animated:YES];
            }
        }];

        if ([tableView.dataSource isKindOfClass:[SearchResultsDataSource class]]) {
            NSString *title = [((SearchResultsDataSource*)tableView.dataSource) titleAtSection:section];
            [view setTitle:title];
        }
        return view;
    }
    return nil;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}


@end
