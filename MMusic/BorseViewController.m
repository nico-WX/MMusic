//
//  BorseViewController.m
//  MMusic
//
//  Created by Magician on 2018/4/26.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <Masonry.h>

#import "BorseViewController.h"
#import "ScreeningViewController.h"
#import "SearchViewController.h"

@interface BorseViewController ()
@property(nonatomic, strong) SearchViewController *searchVC;
//
@property(nonatomic, strong) ScreeningViewController *screeningVC;
//
@property(nonatomic, strong) UIView *screeningView;
//
@property(nonatomic, strong) UICollectionView *collectionView;
@end

@implementation BorseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;

    //将搜索栏 添加到导航栏中, 搜索栏的提示视图添加到视图中
    [self addChildViewController:self.searchVC];
    [self.navigationController.navigationBar addSubview:self.searchVC.serachBar];
    [self.view addSubview:self.searchVC.view];


    [self.view insertSubview:self.screeningView belowSubview:self.searchVC.view];
//    //插入 搜索视图下层
//    [self addChildViewController:self.screeningVC];
//    [self.view insertSubview:_screeningVC.view belowSubview:_searchVC.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [self.searchVC.serachBar setHidden:NO];
    UIView *superview = self.navigationController.navigationBar;
    [self.searchVC.serachBar mas_makeConstraints:^(MASConstraintMaker *make) {
        UIEdgeInsets padding = UIEdgeInsetsMake(0, 4, 0, 4);
        make.edges.mas_equalTo(superview).with.insets(padding);
    }];

}

#pragma mark - getter
- (SearchViewController *)searchVC{
    if (!_searchVC) {
        _searchVC = SearchViewController.new;
    }
    return _searchVC;
}

- (ScreeningViewController *)screeningVC{
    if (!_screeningVC) {
        _screeningVC = ScreeningViewController.new;
    }
    return _screeningVC;
}
-(UIView *)screeningView{
    if (!_screeningView) {
        CGRect frame = CGRectMake(0, 64, CGRectGetWidth(self.view.frame), 44.0f);
        _screeningView = [[UIView alloc] initWithFrame:frame];
        _screeningView.backgroundColor = UIColor.redColor;
    }
    return _screeningView;
}
-(UICollectionView *)collectionView{
    if {
        <#statements#>
    }
    return _collectionView;
}
@end
