//
//  SearchViewController.m
//  MMusic
//
//  Created by Magician on 2018/4/8.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <Masonry.h>
#import "SearchViewController.h"
#import "HintsViewController.h"
#import "ResultsViewController.h"

#import "ChartsViewController.h"

@interface SearchViewController ()<UISearchBarDelegate,UITableViewDelegate>
/**搜索栏*/
@property(nonatomic, strong) UISearchBar *serachBar;
/**搜索提示*/
@property(nonatomic, strong) HintsViewController *hintsVC;
/**搜索结果*/
@property(nonatomic, strong) ResultsViewController *resultsVC;
/**歌单/专辑/语种/风格/场景 等*/
@property(nonatomic, strong) UICollectionView *collectionView;
@end

@implementation SearchViewController

#pragma mark - cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.brownColor;

    //实例搜索栏  并添加到导航栏中
    self.serachBar = ({
        UISearchBar *bar = UISearchBar.new;
        bar.delegate = self;
        bar.barTintColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1.0];
        [self.navigationController.navigationBar addSubview:bar];

        UIView *superview = self.navigationController.navigationBar;
        [self.navigationController.navigationBar addSubview:bar];
        [bar mas_makeConstraints:^(MASConstraintMaker *make) {
            UIEdgeInsets padding = UIEdgeInsetsMake(0, 4, 0, 4);
            make.edges.mas_equalTo(superview).with.insets(padding);
        }];

        bar;
    });

    //实例搜索提示表视图,添加 初始高度0  隐藏
    self.hintsVC = ({
        HintsViewController *hVC = [[HintsViewController alloc] initWithStyle:UITableViewStylePlain];
        //高度0  搜索框获得焦点时显示
        CGFloat x = 0;
        CGFloat y = CGRectGetMaxY(self.navigationController.navigationBar.frame);
        CGFloat w = CGRectGetWidth(self.view.frame);
        CGFloat h = 0;
        CGRect rect = CGRectMake(x, y, w, h);
        hVC.tableView.frame = rect;
        hVC.tableView.delegate = self;
        [self.view addSubview:hVC.tableView];

        hVC;
    });
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.serachBar setHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

#pragma mark - UISearchBarDelegate
//获得焦点
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    searchBar.showsCancelButton = YES;

    //显示提示视图
    [self.navigationController popToViewController:self animated:YES];

    //监听键盘弹出, 获取键盘高度,修改Hints view Frame
    __weak typeof(self) weakSelf = self;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    //键盘Frame改变, 同时更改TableViewFrame
    [center addObserverForName:UIKeyboardWillChangeFrameNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        NSDictionary *info = note.userInfo;
        NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];

        CGRect rect = weakSelf.hintsVC.view.frame;
        CGFloat navH = CGRectGetMaxY(weakSelf.navigationController.navigationBar.frame);
        rect.size.height = CGRectGetMinY(value.CGRectValue) - navH;
        [UIView animateWithDuration:0.7 animations:^{
            weakSelf.hintsVC.view.frame = rect;
        }];
    }];
}
//文本输入
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self.hintsVC showHintsFromTerms:searchText];
}
//搜索点击
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];

    CGFloat tabBarH = CGRectGetHeight(self.tabBarController.tabBar.frame);
    CGRect rect = self.hintsVC.view.frame;
    rect.size.height = CGRectGetHeight(self.view.frame) - CGRectGetMinY(rect) - tabBarH;
    [UIView animateWithDuration:0.5 animations:^{
        self.hintsVC.tableView.frame = rect;
        [self showSearchResultsFromText:searchBar.text];
    }];

}
//搜索栏取消按钮
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    searchBar.showsCancelButton = NO;
    searchBar.text = @"";
    CGRect rect = self.hintsVC.view.frame;
    rect.size.height = 0;
    [UIView animateWithDuration:0.7 animations:^{
        self.hintsVC.view.frame = rect;
    }];
}

#pragma mark - UITableView Delegate (提示表视图代理)
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.hintsVC.tableView) {
        [self.serachBar resignFirstResponder];
        NSString *text = [self.hintsVC.terms objectAtIndex:indexPath.row];
        self.serachBar.text = text;
        [self showSearchResultsFromText:text];
    }

}

#pragma mark - 显示搜索结果
-(void)showSearchResultsFromText:(NSString*) searchText{
    [self.serachBar setHidden:YES];
    self.resultsVC = [[ResultsViewController alloc] initWithSearchText:searchText];
    self.resultsVC.title = searchText;
    [self.navigationController pushViewController:self.resultsVC animated:YES];
}


@end
