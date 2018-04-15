//
//  ChartsViewController.m
//  MMusic
//
//  Created by Magician on 2018/3/30.
//  Copyright © 2018年 com.😈. All rights reserved.
//
#import <Masonry.h>

#import "ChartsViewController.h"
#import "AlbumChartsViewController.h"
#import "MusicVideoChartsViewController.h"
#import "SongChartsViewController.h"
#import "NewCardView.h"


@interface ChartsViewController ()<UIPageViewControllerDelegate,UIPageViewControllerDataSource>

//分页控制器
@property(nonatomic, strong) UIPageViewController *pageViewController;
//PageController
@property(nonatomic, strong) UIPageControl *pageController;

//子控制器数组
@property(nonatomic, strong) NSArray<UIViewController*> *pageList;

//子控制器
@property(nonatomic, strong) AlbumChartsViewController      *albumVC;
@property(nonatomic, strong) MusicVideoChartsViewController *mvVC;
@property(nonatomic, strong) SongChartsViewController       *songVC;

@end

//排行榜视图
@implementation ChartsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    _albumVC= [[AlbumChartsViewController alloc] init];
    _mvVC   = [[MusicVideoChartsViewController alloc] init];
    _songVC = [[SongChartsViewController alloc] init];
    _pageList = @[_albumVC,_mvVC,_songVC];

    //添加到当前导航控制器 子控制器中,   子控制器方便访问导航控制器
    [self addChildViewController:_albumVC];
    [self addChildViewController:_mvVC];
    [self addChildViewController:_songVC];

    //显示PageView
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];

    //设置第一个页
    UIViewController *vc = [self.pageList objectAtIndex:0];
    [self.pageViewController setViewControllers:@[vc,]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:YES
                                     completion:nil];


    self.pageViewController.view.frame = self.view.frame;
    self.pageViewController.view.backgroundColor = UIColor.whiteColor;
    [self.pageViewController didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidAppear:(BOOL)animated{
    for (UIView *view in self.pageViewController.view.subviews) {
        if ([view isKindOfClass:[UIPageControl class]]) {
            self.pageController = (UIPageControl*) view;
            //self.pageController.backgroundColor = UIColor.grayColor;
            self.pageController.currentPageIndicatorTintColor = UIColor.greenColor;
            self.pageController.pageIndicatorTintColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:0.9];

            //下列无效???
            CGRect rect = self.pageController.frame;
            rect.size.height = 20.0f;
            [self.pageController setFrame:rect];

        }
    }
}

#pragma mark Layz
-(UIPageViewController *)pageViewController{
    if (!_pageViewController) {
        _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                              navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                            options:nil];
        _pageViewController.delegate = self;
        _pageViewController.dataSource = self;
        _pageViewController.view.backgroundColor = UIColor.grayColor ;

    }
    return _pageViewController;
}


#pragma  mark UIPageViewController DataSource
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    NSUInteger index = [self.pageList indexOfObject:viewController];
    if (index==0 ||index==NSNotFound) return nil;
    index--;
    return [self.pageList objectAtIndex:index];
}
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    NSUInteger index = [self.pageList indexOfObject:viewController];
    if (index==NSNotFound) return nil;

    index++;
    if (index==self.pageList.count) return nil;

    return [self.pageList objectAtIndex:index];
}

-(NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController{
    return self.pageList.count;
}
-(NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController{
    return 0;
}
@end
