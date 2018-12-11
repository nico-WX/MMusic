//
//  MMMyMusicPageViewController.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/12/11.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <Masonry.h>

#import "MMMyMusicPageViewController.h"
#import "MMSearchTopPageCell.h"
#import "MMModelController.h"

@interface MMMyMusicPageViewController ()<UIPageViewControllerDelegate,UICollectionViewDelegate, UICollectionViewDataSource>
@property(nonatomic, strong) UICollectionView *topPageView;
//@property(nonatomic, strong) MMModelController *modelController;
@end


static NSString *const reuseIdentifier = @"top view reuse identifier";
@implementation MMMyMusicPageViewController

@synthesize pageViewController = _pageViewController;

- (instancetype)initWithDataSourceModel:(MMModelController *)modelController{
    if (self = [super init]) {
        _modelController = modelController;
        [self.pageViewController setDataSource:_modelController];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self.topPageView];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];


    NSLog(@"datasource =%@",self.pageViewController.dataSource);
    MMModelController *controller = (MMModelController*)self.pageViewController.dataSource;
    [controller importDataWithCompletion:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.topPageView reloadData];
            UIViewController *vc = [controller viewControllerAtIndex:0];
            [self.pageViewController setViewControllers:@[vc,] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
            [self.topPageView selectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
        });
    }];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];

    __weak typeof(self) weakSelf = self;
    CGFloat topOffset = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    [self.topPageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.view).mas_offset(topOffset);
        make.left.right.mas_equalTo(weakSelf.view);
        make.height.mas_equalTo(44.0f);
    }];

    [self.pageViewController.view mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.topPageView.mas_bottom).offset(2);
        make.left.bottom.right.mas_equalTo(weakSelf.view);
    }];

}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
//    MMModelController *controller = (MMModelController*)self.pageViewController.dataSource;
//    NSLog(@"count =%ld datasource =%@",[controller numberOfItemsInSection:section],controller);
//    return [controller numberOfItemsInSection:section];
    return [self.modelController numberOfItemsInSection:section];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MMSearchTopPageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];

    [cell.titleLabel setText: [self.modelController titleWhitIndex:indexPath.row]];

//    id obj = self.pageViewController.dataSource;
//    if ([obj isMemberOfClass:[MMModelController class]]) {
//        [cell.titleLabel setText:[((MMModelController*)obj) titleWhitIndex:indexPath.row]];
//    }
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    MMModelController *controller = (MMModelController*)self.pageViewController.dataSource;
    UIViewController *vc = [controller viewControllerAtIndex:indexPath.row];
    NSInteger currentIndex = [controller indexOfViewController:self.pageViewController.viewControllers.firstObject];

    // 确定滚动的方向
    UIPageViewControllerNavigationDirection direction = indexPath.row > currentIndex ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse;
    [self.pageViewController setViewControllers:@[vc,] direction:direction animated:YES completion:nil];
}

-(void)pageViewController:(UIPageViewController *)pageViewController
       didFinishAnimating:(BOOL)finished
  previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers
      transitionCompleted:(BOOL)completed{
    if (completed && finished) {
        UIViewController *currentVC = pageViewController.viewControllers.firstObject;

        MMModelController *controller = (MMModelController*)pageViewController.dataSource;
        NSUInteger index = [controller indexOfViewController:currentVC];

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
        [_topPageView registerClass:[MMSearchTopPageCell class] forCellWithReuseIdentifier:reuseIdentifier];
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
        //数据源从上一级的控制器中设置
    }
    return _pageViewController;
}

@end
