//
//  MMSearchResultsViewController.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/25.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <Masonry.h>
#import <MBProgressHUD.h>

#import "MMSearchResultsViewController.h"
#import "MMSearchTopPageCell.h"
#import "MMSearchData.h"


@interface MMSearchResultsViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,
UIPageViewControllerDelegate>

@property(nonatomic, strong) NSString *term;    //搜索字段
@property(nonatomic, strong) MMSearchData *searchData;  //搜索数据模型控制

//顶部分页指示
@property(nonatomic, strong) UICollectionView *topPageSectionView;
//内容分页控制器
@property(nonatomic, strong) UIPageViewController *pageViewController;
@end

static NSString *const topCellID = @"top cell reuse identifier";
@implementation MMSearchResultsViewController

- (instancetype)initWithTerm:(NSString *)term{
    if (self = [super init]) {
        _searchData = [[MMSearchData alloc] init];
        _term = term;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self.view setBackgroundColor:UIColor.whiteColor];

    //top 分段
    [self.view addSubview:self.topPageSectionView];

    //分页视图
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];

    //hud
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.pageViewController.view animated:YES];
    [hud setMode:MBProgressHUDModeIndeterminate];
    [hud.label setText:@"搜索中"];

    [self.searchData searchDataForTemr:self.term completion:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                [hud setHidden:YES];
                //数据返回, 刷新顶部分页数据
                [self.topPageSectionView reloadData];

                //pageView 显示第一个内容视图
                UIViewController *vc = [self.searchData viewControllerAtIndex:0];
                [self.pageViewController setViewControllers:@[vc,]
                                                  direction:UIPageViewControllerNavigationDirectionForward
                                                   animated:YES
                                                 completion:nil];
                //顶部分页视图选中第一项
                [self.topPageSectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
            }else{
                [hud setMode:MBProgressHUDModeText];
                [hud hideAnimated:YES afterDelay:4.0f];
                [hud.label setText:@"没有搜索到结果"];
            }
        });
    }];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];

    __weak typeof(self) weakSelf = self;
    UIView *superView = self.view;
    CGFloat y = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    [self.topPageSectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superView).offset(y);
        make.left.right.mas_equalTo(superView);
        make.height.mas_equalTo(44.0f);
    }];

    [self.pageViewController.view mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.topPageSectionView.mas_bottom);
        make.left.right.bottom.mas_equalTo(superView);
    }];
}


# pragma mark -  UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.searchData.searchResults.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MMSearchTopPageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:topCellID forIndexPath:indexPath];
    [cell.titleLabel setText:[self.searchData pageTitleForIndex:indexPath.row]];
    return cell;
}
# pragma mark  - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    UIViewController *vc = [self.searchData viewControllerAtIndex:indexPath.row];
    NSInteger currentIndex = [self.searchData indexOfViewController:self.pageViewController.viewControllers.firstObject];

    // 确定滚动的方向
    UIPageViewControllerNavigationDirection direction = indexPath.row > currentIndex ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse;
    [self.pageViewController setViewControllers:@[vc,] direction:direction animated:YES completion:nil];
}

#pragma mark - UIPageViewControllerDelegate
//-(void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers{
//}
-(void)pageViewController:(UIPageViewController *)pageViewController
       didFinishAnimating:(BOOL)finished
  previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers
      transitionCompleted:(BOOL)completed{
    if (completed && finished) {
        UIViewController *currentVC = pageViewController.viewControllers.firstObject;
        NSUInteger index = [self.searchData indexOfViewController:currentVC];

        [self.topPageSectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    }
}

#pragma mark - getter
- (UICollectionView *)topPageSectionView{
    if (!_topPageSectionView) {
        UICollectionViewFlowLayout *layout =[[UICollectionViewFlowLayout alloc] init];
        CGFloat w = CGRectGetWidth(self.view.bounds)/4;
        CGFloat h = 44.0f;
        [layout setItemSize:CGSizeMake(w, h)];
        [layout setMinimumInteritemSpacing:2.0];
        [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];

        //CGRect frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), h);
        _topPageSectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_topPageSectionView registerClass:[MMSearchTopPageCell class] forCellWithReuseIdentifier:topCellID];
        [_topPageSectionView setContentInset:UIEdgeInsetsMake(0, 8, 0, 8)];
        [_topPageSectionView setBackgroundColor:UIColor.whiteColor];
        [_topPageSectionView setDelegate:self];
        [_topPageSectionView setDataSource:self];
    }
    return _topPageSectionView;
}

-(UIPageViewController *)pageViewController{
    if (!_pageViewController) {
        _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                              navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                            options:nil];
        [_pageViewController setDelegate:self];
        [_pageViewController setDataSource:self.searchData];    //数据源从模型控制器中获取
    }
    return _pageViewController;
}

@end


