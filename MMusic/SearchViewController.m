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
@property(nonatomic, strong,readonly) NSArray<NSString*> *terms;
/**搜索结果*/
@property(nonatomic, strong) ResultsViewController *resultsVC;
@end

static NSString *const cellID = @"cellReuseIdentifier";
@implementation SearchViewController

@synthesize terms = _terms;

#pragma mark - cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

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
    [searchBar resignFirstResponder];
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
    cell.textLabel.text = [self.terms objectAtIndex:indexPath.row];
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
    [self.serachBar resignFirstResponder];
    NSString *text = [self.terms objectAtIndex:indexPath.row];
    //选中的文本填入搜索框
    self.serachBar.text = text;
    [self showSearchResultsFromText:text];
}

#pragma mark - 显示搜索结果
-(void)showSearchResultsFromText:(NSString*) searchText{
    [self.serachBar setHidden:YES];
    self.resultsVC = [[ResultsViewController alloc] initWithSearchText:searchText];
    self.resultsVC.title = searchText;
    [self.navigationController pushViewController:self.resultsVC animated:YES];
}

#pragma mark - getter
- (UISearchBar *)serachBar{
    if (!_serachBar) {
        _serachBar = UISearchBar.new;
        _serachBar.delegate = self;

        //监听键盘弹出, 获取键盘高度,修改Hints view Frame
        __weak typeof(self) weakSelf = self;
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        //键盘Frame改变, 同时更改TableViewFrame
        [center addObserverForName:UIKeyboardWillChangeFrameNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            NSDictionary *info = note.userInfo;
            NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];

            CGRect rect = weakSelf.hintsView.frame;
            CGFloat navH = CGRectGetMaxY(weakSelf.navigationController.navigationBar.frame);
            rect.size.height = CGRectGetMinY(value.CGRectValue) - navH;
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
