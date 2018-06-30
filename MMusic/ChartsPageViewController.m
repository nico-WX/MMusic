//
//  ChartsViewController.m
//  MMusic
//
//  Created by Magician on 2018/3/30.
//  Copyright © 2018年 com.😈. All rights reserved.
//
#import <Masonry.h>
#import <objc/runtime.h>

#import "ChartsPageViewController.h"
#import "ChartsViewController.h"

#import "Chart.h"

@interface ChartsPageViewController ()<UIPageViewControllerDelegate,UIPageViewControllerDataSource,UIScrollViewDelegate>
//分页视图控制器
@property(nonatomic, strong) UIPageViewController *pageViewController;
//排行榜结果
@property(nonatomic, strong) NSArray<Chart*> *results;
@end

//排行榜视图
@implementation ChartsPageViewController

#pragma mark - cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    //显示PageView
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];

    //属性设置
    self.pageViewController.view.frame = self.view.frame;
    self.pageViewController.view.backgroundColor = UIColor.whiteColor;
    [self.pageViewController didMoveToParentViewController:self];

    [MusicKit.new.api chartsByType:ChartsAll callBack:^(NSDictionary *json, NSHTTPURLResponse *response) {
        json = [json valueForKey:@"results"];
        if (json) {
            NSMutableArray<Chart*> *array = [NSMutableArray array];
            [json enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull subObjArray, BOOL * _Nonnull stop) {
                [subObjArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [array addObject:[Chart instanceWithDict:obj]];
                }];
            }];
            self.results = array;

            dispatch_async(dispatch_get_main_queue(), ^{
                //设置第一个页
                UIViewController *vc = [self viewControllerAtIndex:0];
                self.title = vc.title;
                [self.pageViewController setViewControllers:@[vc,]
                                                  direction:UIPageViewControllerNavigationDirectionForward
                                                   animated:YES
                                                 completion:nil];
            });
        }
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    for (UIView * view in self.pageViewController.view.subviews) {
        if ([view isKindOfClass:[UIPageControl class]]) {
            UIPageControl *pageCtr = (UIPageControl*)view;
            pageCtr.currentPageIndicatorTintColor = UIColor.greenColor;
            pageCtr.pageIndicatorTintColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        }
    }
}

-(UIViewController*)viewControllerAtIndex:(NSUInteger)index;{
    Chart *chart = [self.results objectAtIndex:index];
    ChartsViewController *vc = [[ChartsViewController alloc] initWithChart:chart];
    vc.title = chart.name;
    return vc;
}
-(NSUInteger)indexOfViewController:(ChartsViewController*) viewController{
    __block NSUInteger index = 0;
    [self.results enumerateObjectsUsingBlock:^(Chart * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj == viewController.chart) {
            index = idx;
        }
    }];
    return index;
}

#pragma mark - getter
-(UIPageViewController *)pageViewController{
    if (!_pageViewController) {
        _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll                                                            navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                            options:nil];
        _pageViewController.delegate = self;
        _pageViewController.dataSource = self;
    }
    return _pageViewController;
}

#pragma  mark - UIPageViewController DataSource
////向前翻页
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    //当前控制器 的上一个控制器
    NSUInteger index = [self indexOfViewController:(ChartsViewController *)viewController];

    //边界
    if (index==0 ||index==NSNotFound) return nil;
    index--;

    return [self viewControllerAtIndex:index];
}
//向后翻页
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    //当前控制器下标
    NSUInteger index = [self indexOfViewController:(ChartsViewController *)viewController];
    //边界
    if (index==NSNotFound) return nil;
    index++;
    if (index >= self.results.count) return nil;

    return [self viewControllerAtIndex:index];
}
-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed{

    if (finished) {
        if (completed) {
            UIViewController *currentVC = pageViewController.viewControllers[0];
            self.title = currentVC.title;
        }
    }
}
-(void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers{

}

@end
