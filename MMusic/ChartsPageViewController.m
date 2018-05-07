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
#import "NewCardView.h"

@interface ChartsPageViewController ()<UIPageViewControllerDelegate,UIPageViewControllerDataSource>
//分页视图控制器
@property(nonatomic, strong) UIPageViewController *pageViewController;
//
@property(nonatomic, strong) UIPageControl *pageCtr;

//子控制器数组
@property(nonatomic, strong) NSArray<UIViewController*> *pageList;

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

    //由于可能的类型只有: playlists, albums, songs, and music-videos.  所以这里生成3个对应的视图控制器
    _albumsVC       = [[ChartsViewController alloc] initWithChartsType:ChartsAlbumsType];
    _playlistsVC    = [[ChartsViewController alloc] initWithChartsType:ChartsPlaylistsType];
    _musicVideosVC  = [[ChartsViewController alloc] initWithChartsType:ChartsMusicVideosType];
    _songsVC        = [[ChartsViewController alloc] initWithChartsType:ChartsSongsType];
    //分页列表
    _pageList = @[_albumsVC,_playlistsVC,_musicVideosVC,_songsVC];

    //添加到当前导航控制器子控制器中, 子控制器方便访问导航控制器
    for (UIViewController *vc in _pageList) {
        [self addChildViewController:vc];
    }

    //显示PageView
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];

    //设置第一个页
    UIViewController *vc = [self.pageList objectAtIndex:0];
    [self.pageViewController setViewControllers:@[vc,]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:YES
                                     completion:nil];

    //属性设置
    self.pageViewController.view.frame = self.view.frame;
    self.pageViewController.view.backgroundColor = UIColor.whiteColor;
    [self.pageViewController didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    for (UIView * view in self.pageViewController.view.subviews) {
        if ([view isKindOfClass:[UIPageControl class]]) {
            self.pageCtr = (UIPageControl*)view;
            self.pageCtr.currentPageIndicatorTintColor = UIColor.greenColor;
            self.pageCtr.pageIndicatorTintColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        }
    }
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
//向前翻页
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    //当前控制器 的上一个控制器
    NSUInteger index = [self.pageList indexOfObject:viewController];

    //边界
    if (index==0 ||index==NSNotFound) return nil;
    index--;

    return [self.pageList objectAtIndex:index];
}
//向后翻页
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    //当前控制器下标
    NSUInteger index = [self.pageList indexOfObject:viewController];
    //边界
    if (index==NSNotFound) return nil;
    index++;
    if (index >= self.pageList.count) return nil;

    return [self.pageList objectAtIndex:index];
}

////总页数
-(NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController{
    return self.pageList.count;
}
//默认显示那一页
-(NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController{
    return 0;
}


@end
