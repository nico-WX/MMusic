//
//  MMSearchMainViewController.m
//  MMusic
//
//  Copyright © 2018年 com.😈. All rights reserved.
//  pod and system
#import <Masonry.h>
#import <MJRefresh.h>

//Controller
#import "MMSearchMainViewController.h"
#import "MMSearchViewController.h"
#import "MMSearchViewControllerAnimation.h"
#import "MMSearchResultsViewController.h"
#import "MMTabBarController.h"

//view  and cell
#import "ChartsMainCell.h"

//model and tool
#import "ChartsData.h"
#import "DataStoreKit.h"
#import "Resource.h"

@interface MMSearchMainViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,MMSearchViewControllerDelegate,UIViewControllerTransitioningDelegate>

@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) MMSearchViewController *searchVC;
@property(nonatomic, strong) MMSearchViewControllerAnimation *animation;

@property(nonatomic, strong) NSArray<NSString*> *cellSearchTerms;
//@property(nonatomic, strong) ChartsData *chartsData;

@end


static NSString *const reuseID = @"cell search term";
@implementation MMSearchMainViewController

- (instancetype)init{
    if (self = [super init]) {
        _animation = [[MMSearchViewControllerAnimation alloc] init];
        _searchVC = [[MMSearchViewController alloc] init];
        [_searchVC setPresentDelegate:self];
        [_searchVC setTransitioningDelegate:self];
    }
    return self;
}

#pragma mark - cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    [self setTitle:@""];

    [self.view addSubview:self.collectionView];
    [self.navigationController.navigationBar addSubview:_searchVC.searchBar];

    // 加载属性列表
    _cellSearchTerms = ({
        NSString *path = [[NSBundle mainBundle] pathForResource:@"SearchContent.plist" ofType:nil];
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
        __block NSArray<NSString*> *temp;
        [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            temp = (NSArray*)obj;
        }];
        temp;
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - <UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.cellSearchTerms.count;

}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ChartsMainCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseID forIndexPath:indexPath];
    [cell.titleLabel setText:[self.cellSearchTerms objectAtIndex:indexPath.row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    ChartsMainCell *cell = (ChartsMainCell*)[collectionView cellForItemAtIndexPath:indexPath];
    MMSearchResultsViewController *resultsVC = [[MMSearchResultsViewController alloc] initWithTerm:cell.titleLabel.text];
    [self.navigationController pushViewController:resultsVC animated:YES];
}


#pragma mark - MMSearchViewControllerDelegate
- (void)presentSearchViewController:(MMSearchViewController *)searchViewController{
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:searchViewController];
    //h这里要嵌入导航控制器中, 搜索VC 需要使用
    [nav setTransitioningDelegate:self];
    [self presentViewController:nav animated:YES completion:nil];
}


#pragma mark - UIViewControllerTransitioningDelegate
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    [_animation setPresent:YES];
    return _animation;
}
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    [_animation setPresent:NO];
    return _animation;
}


#pragma mark - layz Load
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UIEdgeInsets padding = UIEdgeInsetsMake(8, 8, 8, 8);
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        [layout setMinimumLineSpacing:padding.top];
        [layout setMinimumInteritemSpacing:padding.left];

        //两列
        CGFloat w = (CGRectGetWidth(self.view.bounds)-(padding.left*3)) / 2;
        CGFloat h = w/2;
        [layout setItemSize:CGSizeMake(w, h)];

        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        [_collectionView registerClass:[ChartsMainCell class] forCellWithReuseIdentifier:reuseID];
        [_collectionView setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]];


        if (self.tabBarController) {
            MMTabBarController *tabBar = (MMTabBarController*)self.tabBarController;
            CGFloat bottomOffset = CGRectGetHeight([UIScreen mainScreen].bounds) - CGRectGetMinY(tabBar.popFrame);
            padding.bottom += bottomOffset;
        }
        [_collectionView setContentInset:padding];

        [_collectionView setDelegate:self];
        [_collectionView setDataSource:self];
    }
    return _collectionView;
}

@end
