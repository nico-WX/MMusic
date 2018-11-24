//
//  MMSearchViewController.m
//  SearchController
//
//  Created by 🐙怪兽 on 2018/11/22.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <Masonry.h>
#import "MMSearchViewController.h"
#import "ResultsViewController.h"
#import "MMSearchData.h"


@interface MMSearchViewController ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, strong) UITableView *hintsView;
@property(nonatomic, strong) ResultsViewController *resultsViewController;

@property(nonatomic, strong) UIView *fakeNavgationBar;
@property(nonatomic, weak) UIView *searchBarSuperView;

@property(nonatomic, strong) NSArray<NSString*> *hintsTerms;
@end

static NSString *const hintsCellRuseId = @"hints cell Reuse identifier";
@implementation MMSearchViewController

- (instancetype)init{
    if (self =[super init]) {
        CGFloat width = CGRectGetWidth([[UIScreen mainScreen] bounds]);
        // 外部触发 呈现
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0,width, 44.0f)];
        [_searchBar setDelegate:self];

        //假的导航栏
        _fakeNavgationBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 64)];
        [_fakeNavgationBar setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.5]];
        [self.view addSubview:_fakeNavgationBar];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:UIColor.whiteColor];


    CGFloat topOffset = CGRectGetMaxY(self.fakeNavgationBar.frame);
    CGRect frame = self.view.bounds;
    frame.origin.y += topOffset;
    frame.size.height -= topOffset;
    [self.hintsView setFrame:frame];
    //[self.view addSubview:self.hintsView];

    //键盘通知
    //监听键盘Frame 改变通知, 获取键盘高度,修改Hints view Frame 显示
//    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardDidChangeFrameNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
//        NSDictionary *info = note.userInfo;
//        NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
//
//        CGRect rect = self.hintsView.frame;
//        rect.size.height -= CGRectGetHeight(value.CGRectValue);
//        [UIView animateWithDuration:0.5 animations:^{
//            self.hintsView.frame = rect;
//        }];
//    }];
    //刷新布局
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardDidHideNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NSDictionary *info = note.userInfo;
        NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];



        NSLog(@"hide note frame =%@",value);
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardDidShowNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {

        NSDictionary *info = note.userInfo;
        NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];

        CGRect rect = self.hintsView.frame;
        rect.size.height -= CGRectGetHeight(value.CGRectValue);
        [UIView animateWithDuration:0.5 animations:^{
            self.hintsView.frame = rect;
        }];
        NSLog(@"show note frame =%@",value);
    }];
}


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
}
- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];

//    //因为每次监听键盘事件 都会改变提示表视图的Frame  所以这里要立即将视图填充回初始状态;
//    [self.hintsView mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.left.bottom.right.mas_equalTo(self.view);
//        make.top.mas_equalTo(CGRectGetMaxY(self.fakeNavgationBar.frame));
//    }];
}


#pragma mark - <UITableViewDataSource>
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.hintsTerms.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:hintsCellRuseId forIndexPath:indexPath];
    [cell.textLabel setText:[self.hintsTerms objectAtIndex:indexPath.row]];

    return cell;
}

#pragma mark - <UITableViewDelegate>

#pragma mark - <UISearchBarDelegate>
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    if (_presentDelegate && [_presentDelegate respondsToSelector:@selector(presentSearchViewController:)]) {
        [_presentDelegate presentSearchViewController:self];
    }
    [searchBar setShowsCancelButton:YES animated:YES];
    self.searchBarSuperView = [searchBar superview];    //记录原始父视图
    [self.fakeNavgationBar addSubview:searchBar];       //搜索栏添加到当前视图中
    //布局
    [searchBar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(self.fakeNavgationBar);
        make.height.mas_equalTo(CGRectGetHeight(self.fakeNavgationBar.bounds)-20);
    }];
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    NSLog(@"term =%@",searchText);
    if (searchText) {
        [MMSearchData.new searchHintForTerm:searchText complectin:^(NSArray<NSString *> * _Nonnull hints) {
            dispatch_async(dispatch_get_main_queue(), ^{
                CGFloat topOffset = CGRectGetMaxY(self.fakeNavgationBar.frame);
                CGRect frame = self.view.bounds;
                frame.origin.y += topOffset;
                frame.size.height -= topOffset;
                [self.hintsView setFrame:frame];
                [self.view addSubview:self.hintsView];

                self.hintsTerms = hints;
                [self.hintsView reloadData];
            });
        }];
    }else{
        [self.hintsView removeFromSuperview];
        NSLog(@"null");
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self.searchBarSuperView addSubview:searchBar];
    [searchBar setText:nil];
    if (_presentDelegate && [_presentDelegate respondsToSelector:@selector(dismissSearchViewController:)]) {
        [_presentDelegate dismissSearchViewController:self];
    }
    [self.searchBar  setShowsCancelButton:NO animated:YES];
    //重新布局
    [searchBar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.searchBarSuperView);
    }];

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
