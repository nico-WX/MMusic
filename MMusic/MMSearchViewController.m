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

//@property(nonatomic, strong) NSArray<NSString*> *hintsTerms;

@property(nonatomic, assign)CGRect keyboardFrame;
@property(nonatomic, strong)MMSearchData *searchData;
@end

static NSString *const hintsCellRuseId = @"hints cell Reuse identifier";
@implementation MMSearchViewController

- (instancetype)init{
    if (self =[super init]) {
        CGFloat width = CGRectGetWidth([[UIScreen mainScreen] bounds]);
        // 外部触发 呈现
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0,width, 44.0f)];
        [_searchBar setDelegate:self];
        [_searchBar setShowsScopeBar:YES];

        _searchData = [[MMSearchData alloc] init];

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
    [self.view setBackgroundColor:UIColor.grayColor];

    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardDidShowNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NSDictionary *info = note.userInfo;
        NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
        self.keyboardFrame = value.CGRectValue;
    }];
}


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
}


#pragma mark - <UITableViewDataSource>
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.searchData.hintsCount;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:hintsCellRuseId forIndexPath:indexPath];
    [cell.textLabel setText:[self.searchData hintTextForIndex:indexPath.row]];
    return cell;
}

#pragma mark - <UITableViewDelegate>
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *term = cell.textLabel.text;
    [self.searchBar setText:term];

}

#pragma mark - <UISearchBarDelegate>
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    if (_presentDelegate && [_presentDelegate respondsToSelector:@selector(presentSearchViewController:)]) {
        [_presentDelegate presentSearchViewController:self];
    }

    [searchBar setShowsCancelButton:YES animated:YES];
    [self setSearchBarSuperView:[searchBar superview]];    //记录原始父视图
    [self.fakeNavgationBar addSubview:searchBar];       //搜索栏添加到当前视图中


    //布局
    [searchBar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(self.fakeNavgationBar);
        make.height.mas_equalTo(CGRectGetHeight(self.fakeNavgationBar.bounds)-20);
    }];

    if ([searchBar.text isEqualToString:@""]) {
        [self.hintsView removeFromSuperview];
    }
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (![searchText isEqualToString:@""]) {
        [self.searchData searchHintForTerm:searchText complectin:^(MMSearchData * _Nonnull searchData) {
            dispatch_async(dispatch_get_main_queue(), ^{
                CGFloat topOffset = CGRectGetMaxY(self.fakeNavgationBar.frame);
                CGRect frame = self.view.bounds;
                frame.origin.y += topOffset;
                frame.size.height -= topOffset;
                frame.size.height -= CGRectGetHeight(self.keyboardFrame);

                [self.hintsView setFrame:frame];
                [self.view addSubview:self.hintsView];
                [self.hintsView reloadData];
            });
        }];
    }else{
        //移除提示视图, 显示self.view
        [self.hintsView removeFromSuperview];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self.searchBarSuperView addSubview:searchBar];
    [searchBar setText:@""];
    if (_presentDelegate && [_presentDelegate respondsToSelector:@selector(dismissSearchViewController:)]) {
        [_presentDelegate dismissSearchViewController:self];
    }

    [searchBar  setShowsCancelButton:NO animated:YES];
    [self.hintsView removeFromSuperview];

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
