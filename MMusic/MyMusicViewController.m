//
//  MyMusicViewController.m
//  MMusic
//
//  Created by Magician on 2017/11/8.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import <Masonry.h>

#import "MyMusicViewController.h"
#import "MMSearchTopPageCell.h"
#import "MMTopPageLibraryData.h"


/**
 1. 分本地和iCloud,
 2. 本视图控制器中,包含1个pageViewController, 该PageViewController显示另外的两个内容PageViewController

 */

@interface MyMusicViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UIPageViewControllerDelegate>
@property(nonatomic, strong) UICollectionView *topPageView; //iCloud & Local
@property(nonatomic, strong) UIPageViewController *pageViewController;

@property(nonatomic, strong) MMTopPageLibraryData *topPageData; // 分页控制器的 dataSource
@end

static NSString *reuseId = @"top cell identifier";
@implementation MyMusicViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"我的音乐"];

    //初始化数据源
    _topPageData = [[MMTopPageLibraryData alloc] init];

    [self.view addSubview:self.topPageView];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];

    // 显示第一个分页
    UIViewController *vc = [self.topPageData viewControllerAtIndex:0];
    [self.pageViewController setViewControllers:@[vc,] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    [self.topPageView selectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];

    __weak typeof(self) weakSelf = self;
    //CGFloat topOffset = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    [self.topPageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.navigationController.navigationBar.mas_bottom);
        make.left.right.mas_equalTo(weakSelf.view);
        make.height.mas_equalTo(44.0f);
    }];

    [self.pageViewController.view mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.topPageView.mas_bottom);
        make.left.bottom.right.mas_equalTo(weakSelf.view);
    }];

}

#pragma mark - 集合视图 数据源 与 代理

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.topPageData.modelControllers.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MMSearchTopPageCell *cell = (MMSearchTopPageCell*)[collectionView dequeueReusableCellWithReuseIdentifier:reuseId forIndexPath:indexPath];

    [cell.titleLabel setText:[self.topPageData titleWhitIndex:indexPath.row]];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    UIViewController *vc = [self.topPageData viewControllerAtIndex:indexPath.row];
    NSInteger currentIndex = [self.topPageData indexOfViewController:self.pageViewController.viewControllers.firstObject];

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
        NSUInteger index = [self.topPageData indexOfViewController:currentVC];
    

        [self.topPageView selectItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    }
}

#pragma mark - getter

- (UICollectionView *)topPageView{
    if (!_topPageView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        [layout setItemSize:CGSizeMake(100, 44.0f)];

        _topPageView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_topPageView registerClass:[MMSearchTopPageCell class] forCellWithReuseIdentifier:reuseId];
        [_topPageView setDelegate:self];
        [_topPageView setDataSource:self];
        [_topPageView setBackgroundColor:UIColor.whiteColor];
    }
    return _topPageView;
}

- (UIPageViewController *)pageViewController{
    if (!_pageViewController) {
        _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];

        [_pageViewController setDelegate:self];
        [_pageViewController setDataSource:self.topPageData];
        [_pageViewController.view setBackgroundColor:UIColor.whiteColor];
    }
    return _pageViewController;
}

@end
