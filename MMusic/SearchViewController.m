//
//  SearchViewController.m
//  MMusic
//
//  Created by Magician on 2018/4/8.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <Masonry.h>
#import "SearchViewController.h"
#import "ResultsViewController.h"
#import "RequestFactory.h"

@interface SearchViewController ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>
/**提示视图*/
@property(nonatomic, strong) UITableView *hintsView;
/**提示数据*/
@property(nonatomic, strong) NSArray<NSString*> *terms;
/**搜索结果*/
@property(nonatomic, strong) ResultsViewController *resultsVC;
@end

static NSString *const cellID = @"cellReuseIdentifier";
@implementation SearchViewController

@synthesize serachBar = _serachBar;
#pragma mark - cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    /**
     1. 当搜索栏未获得焦点时, hintsView 高度为0,隐藏在父视图上方;
     2. 当搜索栏获得焦点时, 通过接受键盘弹出通知, 改变hintsView高度
     3. 选中cell 或者 搜索按钮点击时 显示搜索结果视图
     */

    //替换视图
    self.view = self.hintsView;
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
}
//文本输入
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self showHintsFromTerms:searchText];
}
//搜索点击
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.serachBar resignFirstResponder];

    [self showSearchResultsFromText:searchBar.text];
}
//搜索栏取消按钮 隐藏提示栏
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    searchBar.showsCancelButton = NO;
    searchBar.text = @"";
    CGRect rect = self.hintsView.frame;
    rect.size.height = 0;
    [UIView animateWithDuration:0.7 animations:^{
        self.hintsView.frame = rect;
    }];
}

#pragma mark - UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.terms.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    if (self.terms.count > 0) {
        cell.textLabel.text = [self.terms objectAtIndex:indexPath.row];
    }

    return cell;
}
- (void)showHintsFromTerms:(NSString *)term{
    NSURLRequest *request = [[RequestFactory new] fetchSearchHintsForTerms:term];
    [self dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *json = [self serializationDataWithResponse:response data:data error:nil];
        if ([json valueForKeyPath: @"results.terms"]) {
            self->_terms = [json valueForKeyPath:@"results.terms"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.hintsView reloadData];
            });
        }
    }];
}

#pragma mark - UITableView Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *text = [self.terms objectAtIndex:indexPath.row];
    [self.serachBar resignFirstResponder];

    //选中的文本填入搜索框
    self.serachBar.text = text;
    [self showSearchResultsFromText:text];
}

#pragma mark - 显示搜索结果
-(void)showSearchResultsFromText:(NSString*) searchText{
    [self.serachBar setHidden:YES];

    self.resultsVC = [[ResultsViewController alloc] initWithSearchText:searchText];
    [self.navigationController pushViewController:self.resultsVC animated:YES];
}

#pragma mark - getter
- (UISearchBar *)serachBar{
    if (!_serachBar) {
        _serachBar = [UISearchBar new] ;
        _serachBar.delegate = self;
        [_serachBar setBackgroundColor:UIColor.clearColor];

        //监听键盘Frame 改变通知, 获取键盘高度,修改Hints view Frame 显示
        __weak typeof(self) weakSelf = self;
        [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillChangeFrameNotification
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification * _Nonnull note) {
            NSDictionary *info = note.userInfo;
            NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];

            CGRect rect = weakSelf.hintsView.frame;
            CGFloat navMaxY = CGRectGetMaxY(weakSelf.navigationController.navigationBar.frame);
            rect.size.height = CGRectGetMinY(value.CGRectValue) - navMaxY;
            [UIView animateWithDuration:0.7 animations:^{
                weakSelf.hintsView.frame = rect;
            }];
        }];
    }
    return _serachBar;
}

-(UITableView *)hintsView{
    if (!_hintsView) {
        CGFloat x = 0;
        CGFloat y = CGRectGetMaxY(self.navigationController.navigationBar.frame);
        CGFloat w = CGRectGetWidth(self.view.frame);
        CGFloat h = 0;
        _hintsView = [[UITableView alloc] initWithFrame:CGRectMake(x, y, w, h) style:UITableViewStylePlain];
        [_hintsView registerClass:UITableViewCell.class forCellReuseIdentifier:cellID];
        _hintsView.delegate = self;
        _hintsView.dataSource = self;
    }
    return _hintsView;
}

@end
