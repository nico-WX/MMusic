//
//  ChartsMainViewController.m
//  MMusic
//
//  Copyright © 2018年 com.😈. All rights reserved.
//  pod and system
#import <Masonry.h>
#import <MJRefresh.h>

//Controller
#import "ChartsMainViewController.h"
#import "MMSearchViewController.h"
#import "MMSearchViewControllerAnimation.h"

//view  and cell
#import "ChartsMainCell.h"

//model and tool
#import "ChartsData.h"
#import "DataStoreKit.h"
#import "Resource.h"

@interface ChartsMainViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,MMSearchViewControllerDelegate,UIViewControllerTransitioningDelegate>

@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) MMSearchViewController *searchVC;
@property(nonatomic, strong) MMSearchViewControllerAnimation *animation;

@property(nonatomic, strong) NSArray<NSString*> *cellSearchTerms;
@property(nonatomic, strong)ChartsData *chartsData;

@end

static NSString *const reuseID = @"chartCell";
@implementation ChartsMainViewController


#pragma mark - cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;

    [self.view addSubview:self.collectionView];
    [self.collectionView setContentInset:UIEdgeInsetsMake(4, 4, 10, 4)];

    _animation = [MMSearchViewControllerAnimation new];
    _searchVC = [[MMSearchViewController alloc] init];
    [_searchVC setPresentDelegate:self];
    [_searchVC setTransitioningDelegate:self];
    [self.navigationController.navigationBar addSubview:_searchVC.searchBar];

//
//    UINavigationBar *bar = [UINavigationBar alloc] init

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

}


#pragma mark - MMSearchViewControllerDelegate
- (void)presentSearchViewController:(MMSearchViewController *)searchViewController{
    [self presentViewController:searchViewController animated:YES completion:nil];
}
-(void)dismissSearchViewController:(MMSearchViewController *)searchViewcontroller{
    [self dismissViewControllerAnimated:YES completion:nil];
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
        CGFloat w = (CGRectGetWidth(self.view.bounds)-(padding.left*3))/2;
        CGFloat h = w/2;
        [layout setItemSize:CGSizeMake(w, h)];


        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        [_collectionView registerClass:[ChartsMainCell class] forCellWithReuseIdentifier:reuseID];
        [_collectionView setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0]];
        [_collectionView setContentInset:UIEdgeInsetsMake(0, padding.left, 0, padding.right)];

        [_collectionView setDelegate:self];
        [_collectionView setDataSource:self];
    }
    return _collectionView;
}



@end
