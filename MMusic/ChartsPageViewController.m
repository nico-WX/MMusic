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
#import "ResponseRoot.h"

@interface ChartsPageViewController ()<UIPageViewControllerDelegate,UIPageViewControllerDataSource,UIScrollViewDelegate>
//分页视图控制器
@property(nonatomic, strong) UIPageViewController *pageViewController;
//排行榜结果
@property(nonatomic, strong) NSArray<NSDictionary<NSString*,ResponseRoot*>*> *results;

//子控制器数组
//@property(nonatomic, strong) NSArray<UIViewController*> *pageList;

//子控制器
@property(nonatomic, strong) ChartsViewController *albumsVC;
@property(nonatomic, strong) ChartsViewController *playlistsVC;
@property(nonatomic, strong) ChartsViewController *musicVideosVC;
@property(nonatomic, strong) ChartsViewController *songsVC;

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
            NSMutableArray<NSDictionary<NSString*, ResponseRoot*> *> *array = [NSMutableArray array];
            [json enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                ResponseRoot *root = [ResponseRoot instanceWithDict:obj];
                [array addObject:@{key:root}];
            }];
            self.results = array;

            dispatch_async(dispatch_get_main_queue(), ^{
                //设置第一个页
                UIViewController *vc = [self viewControllerAtIndex:0];
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

//-(void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:animated];
//    for (UIView * view in self.pageViewController.view.subviews) {
//        if ([view isKindOfClass:[UIPageControl class]]) {
//            self.pageCtr = (UIPageControl*)view;
//            self.pageCtr.currentPageIndicatorTintColor = UIColor.greenColor;
//            self.pageCtr.pageIndicatorTintColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
//        }
//    }
//}

-(UIViewController*)viewControllerAtIndex:(NSUInteger)index;{
    NSDictionary<NSString*,ResponseRoot*> *dict = [self.results objectAtIndex:index];
    NSString *title = dict.allKeys.firstObject;
    ResponseRoot *root = dict.allValues.firstObject;

    ChartsViewController *vc = [[ChartsViewController alloc] initWithResponseRoot:root];
    vc.title = title;
    return vc;
}
-(NSUInteger)indexOfViewController:(ChartsViewController*) viewController{
    __block NSUInteger index = 0;
    for (NSDictionary<NSString*,ResponseRoot*> *dict in self.results) {
        [dict.allValues enumerateObjectsUsingBlock:^(ResponseRoot * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj == viewController.root) {
                index = idx;
            }
        }];
    }
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


@end
