//
//  MMSearchViewController.m
//  SearchController
//
//  Created by 🐙怪兽 on 2018/11/22.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <Masonry.h>
#import "MMSearchViewController.h"
#import "MMSearchResultsViewController.h"
#import "MMSearchData.h"

@interface MMSearchViewController ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, strong) MMSearchResultsViewController *searchResultsVC;    //结果显示控制器

@property(nonatomic, strong) UITableView *hintsView;    //搜索提示栏
@property(nonatomic, weak)   UIView *searchBarSuperView;    //搜索栏从外部进入搜索控制器时,会添加到搜索控制中, 退出控制器时,再添加回去
@property(nonatomic, assign) CGRect keyboardFrame;      // 记录键盘的Frame, 用于调整提示窗口;

@property(nonatomic, strong) MMSearchData *searchData;  //数据模型控制器
@end

static NSString *const hintsCellRuseId = @"hints cell Reuse identifier";
@implementation MMSearchViewController

//@synthesize searchBar = _searchBar;

- (instancetype)init{
    if (self =[super init]) {
        _searchData = [[MMSearchData alloc] init];

        CGFloat width = CGRectGetWidth([[UIScreen mainScreen] bounds]) - 16;
        _searchBar = [[UISearchBar alloc] initWithFrame: CGRectMake(8, 0, width, 44.0f)];
        [_searchBar setDelegate:self];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:UIColor.lightGrayColor];

    //键盘弹出 与隐藏消息
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserverForName:UIKeyboardDidShowNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NSDictionary *info = note.userInfo;
        NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
        self.keyboardFrame = value.CGRectValue;
    }];
    [center addObserverForName:UIKeyboardDidHideNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self.hintsView removeFromSuperview];
    }];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.searchBar resignFirstResponder];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
}

#pragma mark - <UITableViewDataSource>
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.searchData.searchHints.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:hintsCellRuseId forIndexPath:indexPath];
    [cell.textLabel setText:[self.searchData.searchHints  objectAtIndex:indexPath.row]];
    return cell;
}

#pragma mark - <UITableViewDelegate>
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *term = cell.textLabel.text;
    [self.searchBar setText:term];
    [self searchText:term];
}

#pragma mark - <UISearchBarDelegate>
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{

    [self.searchResultsVC.view removeFromSuperview];
    //未入栈,代理显示本视图控制器
    if (_presentDelegate && [_presentDelegate respondsToSelector:@selector(presentSearchViewController:)] && !self.navigationController) {
        [_presentDelegate presentSearchViewController:self];
        [searchBar setShowsCancelButton:YES animated:YES];
        [self setSearchBarSuperView:[searchBar superview]];             //记录原始父视图,
        [self.navigationController.navigationBar addSubview:searchBar]; //搜索栏添加到当前视图中
    }

    //无字符串时, 隐藏提示栏
    if ([searchBar.text isEqualToString:@""]) {
        [self.hintsView removeFromSuperview];
    }else{
        [self.view addSubview:self.hintsView];
    }
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self.searchResultsVC.view removeFromSuperview];
    if (![searchText isEqualToString:@""]) {
        [self.searchData searchHintForTerm:searchText complectin:^(BOOL success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    [self.view addSubview:self.hintsView];

                    __weak typeof(self) weakSelf = self;
                    [self.hintsView mas_remakeConstraints:^(MASConstraintMaker *make) {
                        CGFloat y = CGRectGetMaxY(weakSelf.navigationController.navigationBar.frame);
                        CGFloat h = CGRectGetHeight([UIScreen mainScreen].bounds) - (y+CGRectGetHeight(weakSelf.keyboardFrame));

                        make.top.mas_equalTo(weakSelf.view).offset(y);
                        make.left.right.mas_equalTo(weakSelf.view);
                        make.height.mas_equalTo(h);
                    }];
                    [self.hintsView reloadData];
                }
            });
        }];
    }else{
        //移除提示视图, 显示self.view
        [self.hintsView removeFromSuperview];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self searchText:searchBar.text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    //[self.searchResultsVC.view removeFromSuperview];

    [searchBar setText:@""];
    [searchBar  setShowsCancelButton:NO animated:YES];

    [self.hintsView removeFromSuperview];
    [self.searchBarSuperView addSubview:searchBar];

    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}



- (void)searchText:(NSString*)term{
    [self.searchBar resignFirstResponder]; //执行搜索, 隐藏键盘
    [self.hintsView removeFromSuperview];   //移除提示表

    self.searchResultsVC = [[MMSearchResultsViewController alloc] initWithTerm:term];
    CGRect frame = self.view.bounds;
    frame.origin.y += CGRectGetMaxY(self.navigationController.navigationBar.frame);
    frame.size.height -= CGRectGetHeight(self.navigationController.navigationBar.bounds);
    self.searchResultsVC.view.frame = frame;
    [self.view addSubview:self.searchResultsVC.view];
}

- (UITableView *)hintsView{
    if (!_hintsView) {
        _hintsView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_hintsView registerClass:[UITableViewCell class] forCellReuseIdentifier:hintsCellRuseId];
        [_hintsView setDelegate:self];
        [_hintsView setDataSource:self];
    }
    return _hintsView;
}


@end
