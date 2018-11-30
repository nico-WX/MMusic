//
//  MMCloudLibraryViewController.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/30.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <Masonry.h>

#import "MMCloudLibraryViewController.h"
#import "MMSearchTopPageCell.h"
#import "MMLibraryData.h"

@interface MMCloudLibraryViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UIPageViewControllerDelegate>
@property(nonatomic, strong) UICollectionView *topPageView;
@property(nonatomic, strong) UIPageViewController *pageViewController;
@property(nonatomic, strong) MMLibraryData *librarData;

@end

static NSString *reuseId = @"top cell identifier";
@implementation MMCloudLibraryViewController

- (instancetype)init{
    if (self = [super init]) {
        _librarData = [[MMLibraryData alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"iCloud Music"];

    [self.view addSubview:self.topPageView];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];


    void(^completion)(BOOL success)  = ^(BOOL success){
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                [self.topPageView reloadData];

                UIViewController *vc = [self.librarData viewControllerAtIndex:0];
                [self.pageViewController setViewControllers:@[vc,] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
                [self.topPageView selectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
            }
        });
    };

    [self.librarData requestAllLibraryResource:completion];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.librarData.results.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MMSearchTopPageCell *cell = (MMSearchTopPageCell*)[collectionView dequeueReusableCellWithReuseIdentifier:reuseId forIndexPath:indexPath];
    //self.librarData
    [cell.titleLabel setText:[self.librarData titleWhitIndex:indexPath.row]];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    UIViewController *vc = [self.librarData viewControllerAtIndex:indexPath.row];
    NSInteger currentIndex = [self.librarData indexOfViewController:self.pageViewController.viewControllers.firstObject];

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
        //self.librarData
        NSUInteger index = [self.librarData indexOfViewController:currentVC];

        [self.topPageView selectItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    }
}


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
        [_pageViewController setDataSource:self.librarData];
        [_pageViewController.view setBackgroundColor:UIColor.whiteColor];
    }
    return _pageViewController;
}

@end
