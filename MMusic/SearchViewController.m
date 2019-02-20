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
#import "MusicVideo.h"
#import "ResponseRoot.h"

#import "MPMusicPlayerController+ResourcePlaying.h"
#import "UITableView+Extension.h"

//分割代理方法
@interface SearchViewController (Delegate)<UITableViewDelegate,DataSourceDelegate>
@end

@interface SearchViewController ()

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

    self.searchHistoryDataSource = [[SearchHistoryDataSource alloc] initWithTableView:self.searchHistoryView
                                                                           identifier:identifier
                                                                    sectionIdentifier:nil
                                                                             delegate:self];

    [self setDefinesPresentationContext:YES]; //当前环境呈现
    [self.navigationController.navigationBar setPrefersLargeTitles:YES];
    [self.navigationItem setSearchController:self.searchController];
    [self.navigationItem setHidesSearchBarWhenScrolling:NO];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];

    [_searchHistoryView setFrame:self.view.bounds];
    [_searchController.view setFrame:self.view.bounds];
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
        [_searchHistoryView hiddenSurplusSeparator];

    }
    return _searchHistoryView;
}

- (UISearchController *)searchController{
    if (!_searchController) {
        SearchResultsController *vc = [[SearchResultsController alloc] init];
        //成为搜索结果表视图代理, 选中cell 压栈到导航控制器中 <<<<<<<<<<<<<<<<<<<<<<<
        [vc.searchResultsView setDelegate:self];

        _searchController = [[UISearchController alloc] initWithSearchResultsController:vc];
        [_searchController setSearchResultsUpdater:vc];
        [_searchController.searchBar setAutocorrectionType:UITextAutocorrectionTypeNo];
        [_searchController.searchBar setPlaceholder:@"搜索单曲,专辑等"];
        [_searchController setDimsBackgroundDuringPresentation:NO];
    }
    return _searchController;
}

@end


@implementation SearchViewController (Delegate)

#pragma mark - DataSourceDelegate
- (void)configureCell:(UITableViewCell*)cell item:(NSString*)item{
    [cell.textLabel setText:item];
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    if (tableView == self.searchHistoryView) {
        // 选中搜索历史cell 搜索字段
        NSString *term = cell.textLabel.text;
        [_searchController setActive:YES];  // 激活搜索控制器
        UISearchBar *searchBar = _searchController.searchBar;
        [searchBar setText:term];
        [searchBar.delegate searchBarSearchButtonClicked:searchBar];
    }else{

        //搜索结果TableView 代理, 选中song 播放, 选中mv 跳转到music 播放, 其他显示详情;
        if ([cell isKindOfClass:[SearchResultsCell class]]) {

            // 区分不同的资源类型 做出响应
            NSArray<Resource*> *resourceList = [((SearchResultsDataSource*)tableView.dataSource) allResurceAtSection:indexPath.section];
            Resource *res = [resourceList firstObject];

            // 播放song
            if ([res.type isEqualToString:@"songs"]) {
                NSMutableArray<Song*> *songs = [NSMutableArray array];
                for (Resource *songResource in resourceList) {
                    Song *song = [Song instanceWithResource:songResource];
                    [songs addObject:song];
                }
                [MainPlayer playSongs:songs startIndex:indexPath.row];

                //播放MV
            } else if ([res.type isEqualToString:@"music-videos"]) {
                NSMutableArray<MusicVideo*> *mvs = [NSMutableArray array];
                for (Resource *resource in resourceList) {
                    MusicVideo *mv = [MusicVideo instanceWithResource:resource];
                    [mvs addObject:mv];
                }
                [MainPlayer playMusicVideos:mvs startIndex:indexPath.row];

                //显示资源详细song列表
            }else{

                Resource *detailResource = [resourceList objectAtIndex:indexPath.row];
                ResourceDetailViewController *detail = [[ResourceDetailViewController alloc] initWithResource:detailResource];
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
         //更多按钮事件
        [view.showMoreButton handleControlEvent:UIControlEventTouchUpInside withBlock:^{
            if ([tableView.dataSource isKindOfClass:[SearchResultsDataSource class]]) {
                ResponseRoot *root = [((SearchResultsDataSource*)tableView.dataSource) dataWithSection:section];
                ShowAllSearchResultsViewController *allVC = [[ShowAllSearchResultsViewController alloc] initWithResponseRoot:root];
                [allVC setTitle:view.title];
                [self.navigationController pushViewController:allVC animated:YES];
            }
        }];

        if ([tableView.dataSource isKindOfClass:[SearchResultsDataSource class]]) {
           ResponseRoot *root =  [((SearchResultsDataSource*)tableView.dataSource) dataWithSection:section];
            //搜索结果节头是否显示更多按钮
            if (!root.next) {
                [view.showMoreButton setHidden:YES];
            }else{
                [view.showMoreButton setHidden:NO];
            }

            NSString *title = [((SearchResultsDataSource*)tableView.dataSource) titleAtSection:section];
            [view setTitle:title];
        }
        return view;
    }
    return nil;
}


@end
