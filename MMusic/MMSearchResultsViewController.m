//
//  MMSearchResultsViewController.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/25.
//  Copyright © 2018 com.😈. All rights reserved.
//


#import "MMSearchResultsViewController.h"
#import "MMSearchTopPageCell.h"
#import "MMSearchData.h"



@interface MMSearchResultsViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,
UIPageViewControllerDelegate>

@property(nonatomic, strong) NSString *term;
@property(nonatomic, strong) MMSearchData *searchData;

//顶部分页段
@property(nonatomic, strong) UICollectionView *topPageSectionView;
//分页控制器
@property(nonatomic, strong) UIPageViewController *pageViewController;
@end

static NSString *const topCellID = @"top cell reuse identifier";
@implementation MMSearchResultsViewController

- (instancetype)initWithTerm:(NSString *)term{
    if (self = [super init]) {
        _term = term;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self.view addSubview:self.topPageSectionView];

    [MMSearchData.new searchDataForTemr:self.term completion:^(MMSearchData * _Nonnull searchData) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.searchData = searchData;
            [self.topPageSectionView reloadData];

            //数据返回,添加分页控制器
            [self addChildViewController:self.pageViewController];

            [self.view addSubview:self.pageViewController.view];
            [self.pageViewController didMoveToParentViewController:self];
            //pageView 显示第一个内容视图
            UIViewController *vc = [searchData viewControllerAtIndex:0];
            [self.pageViewController setViewControllers:@[vc,]
                                                direction:UIPageViewControllerNavigationDirectionForward
                                                 animated:YES
                                               completion:nil];
            //选中第一项
            [self.topPageSectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
        });
    }];
}

#pragma mark - Protocol ----------Begin-------------------------
# pragma mark  UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.searchData.sectionCount;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MMSearchTopPageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:topCellID forIndexPath:indexPath];
    [cell.titleLabel setText:[self.searchData pageTitleForIndex:indexPath.row]];
    
    return cell;
}
# pragma mark  UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    UIViewController *vc = [self.searchData viewControllerAtIndex:indexPath.row];
    NSInteger currentIndex = [self.searchData indexOfViewController:self.pageViewController.viewControllers.firstObject];

    // 确定滚动的方向
    UIPageViewControllerNavigationDirection direction = indexPath.row > currentIndex ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse;
    [self.pageViewController setViewControllers:@[vc,] direction:direction animated:YES completion:nil];
}

#pragma mark - UIPageViewControllerDelegate
-(void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers{
   

}
-(void)pageViewController:(UIPageViewController *)pageViewController
       didFinishAnimating:(BOOL)finished
  previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers
      transitionCompleted:(BOOL)completed{

    if (completed) {
        if (finished) {
            UIViewController *currentVC = pageViewController.viewControllers.firstObject;
            NSUInteger index = [self.searchData indexOfViewController:currentVC];

            [self.topPageSectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
        }
    }
}


//#pragma mark  Protocol ----------End-------------------------

#pragma mark - layz Load
- (UICollectionView *)topPageSectionView{
    if (!_topPageSectionView) {
        UICollectionViewFlowLayout *layout =[[UICollectionViewFlowLayout alloc] init];
        CGFloat w = CGRectGetWidth(self.view.bounds)/4;
        CGFloat h = 44.0f;
        [layout setItemSize:CGSizeMake(w, h)];
        [layout setMinimumInteritemSpacing:1.0];
        [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];

        CGRect frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), h);
        _topPageSectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
        [_topPageSectionView registerClass:[MMSearchTopPageCell class] forCellWithReuseIdentifier:topCellID];
        [_topPageSectionView setContentInset:UIEdgeInsetsMake(0, 10, 0, 10)];
        [_topPageSectionView setBackgroundColor:UIColor.whiteColor];
        [_topPageSectionView setDelegate:self];
        [_topPageSectionView setDataSource:self];
        [_topPageSectionView setAllowsSelection:YES];
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

        CGRect frame = self.view.bounds;
        frame.origin.y += CGRectGetMaxY(_topPageSectionView.frame);
        frame.size.height -= CGRectGetMaxY(_topPageSectionView.frame);

        NSLog(@"page frame =%@",NSStringFromCGRect(frame));

        [_pageViewController.view setFrame:frame];
    }
    return _pageViewController;
}

@end


