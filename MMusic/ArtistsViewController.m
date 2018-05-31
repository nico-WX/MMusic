//
//  ArtistsViewController.m
//  MMusic
//
//  Created by Magician on 2018/5/24.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import "ArtistsViewController.h"
#import "ArtistsContentViewController.h"
#import "RequestFactory.h"
#import "Resource.h"
#import "ResponseRoot.h"
#import "Artwork.h"

@interface ArtistsViewController ()<UIPageViewControllerDelegate,UIPageViewControllerDataSource,UIScrollViewDelegate>

//基本 下拉  控件悬停
@property(nonatomic, strong) UIImageView *imageView;            //艺人照片
@property(nonatomic, strong) UIScrollView *scrollView;          //滚动视图
@property(nonatomic, strong) UIView *contentView;               //分段控制器  和内容视图(pageView)
@property(nonatomic, strong) UISegmentedControl *segmentControl;//分段控制器
@property(nonatomic, assign) NSUInteger currentIndex;           //当前选择的下标
@property(nonatomic, assign) CGFloat topOffset;                 //偏移

//艺人名称
@property(nonatomic, copy) NSString *artistsName;

/**
 艺人相关数据
 */
@property(nonatomic, strong)NSArray<NSDictionary<NSString*,ResponseRoot*>*> *results;

//分页
@property(nonatomic, strong) UIPageViewController *pageViewController;

@end


@implementation ArtistsViewController

-(instancetype)initWithArtistsName:(NSString *)artistsName{
    if ( self = [super init]) {
        _artistsName = artistsName;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    /**
     1.在 self.view 中分别添加 imageView 和 scrollView;
     2.在 scrollView 中添加 contentView;
     3.在 contentView 中添加 分段控制器和pageView
     */

    self.topOffset = CGRectGetHeight(self.navigationController.navigationBar.frame)+20;

    [self.view addSubview:self.imageView];
    [self.view addSubview:self.scrollView];

    [self.scrollView addSubview:self.contentView];

    [self.contentView addSubview:self.segmentControl];
    [self.contentView addSubview:self.pageViewController.view];


    [self addChildViewController:self.pageViewController];
    [self.pageViewController didMoveToParentViewController:self];

    //数据请求
    [self requestFromArtistName:self.artistsName];

    self.view.backgroundColor = UIColor.whiteColor ;

}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];


    //导航栏透明
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}


#pragma mark - UIPageViewControllerDataSource
//返回右边控制器
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{

    NSUInteger index = [self indexForViewController:(ArtistsContentViewController*)viewController];
    if (NSNotFound == index) return nil;

    index++;
    if (index >= self.results.count) nil;

    return [self viewControllerAtIndex:index];
}
//返回左边控制器
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    NSUInteger index = [self indexForViewController:(ArtistsContentViewController *)viewController];
    if (0 == index || index == NSNotFound) return nil;

    index--;



    return [self viewControllerAtIndex:index];
}


#pragma mark - UIPageViewControllerDelegate
//滑动完成后,  更新分段控制选中的item
-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed{
    if (completed) {
        if (finished) {
            //完成滑动
            UIViewController *contentVC = pageViewController.viewControllers.lastObject;
            NSUInteger index = [self indexForViewController:(ArtistsContentViewController*)contentVC];

            [self.segmentControl setSelectedSegmentIndex:index];
        }
    }
}

#pragma mark - UIScrollViewDelegate
// 处理下拉放大  和上拉到顶部 悬停分段控制器
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{

    CGFloat y = scrollView.contentOffset.y;

    //悬停控件
    CGFloat imageH = CGRectGetHeight(self.imageView.frame)-self.topOffset;


    if (y >= imageH) {
        self.segmentControl.frame = ({
            CGRect frame = self.segmentControl.frame;
            frame.origin.y = self.topOffset;
            frame;
        });

        [self.view addSubview:self.segmentControl];
    }else{

        self.segmentControl.frame = ({
            CGRect frame = self.segmentControl.frame;
            frame.origin.y = 0;
            frame;
        });

        [self.contentView addSubview:self.segmentControl];
    }

    //缩放
    if (y < 0) {
        CGFloat scale = 1 - (scrollView.contentOffset.y / 100);
        scale = (scale >= 1) ? scale : 1;
        self.imageView.transform = CGAffineTransformMakeScale(scale, scale);
    }else{//上拉
        self.imageView.transform = CGAffineTransformMakeScale(1, 1);
    }
}


#pragma mark -helper
//视图控制器下标
-(NSUInteger) indexForViewController:(ArtistsContentViewController*) vc{
    NSUInteger index = 0;
    ResponseRoot *root = vc.responseRoot;
    for (NSDictionary<NSString*,ResponseRoot*> *dict in self.results) {
        if (root == dict.allValues.lastObject) {
            index = [self.results indexOfObject:dict];
        }
    }
    return index;
}
//生成下标下的视图控制器
-(UIViewController*)viewControllerAtIndex:(NSUInteger)index{
    if ( 0 == self.results.count || index >= self.results.count) return nil;

    NSDictionary<NSString*,ResponseRoot*> *dict = [self.results objectAtIndex:index];
    NSString *title = dict.allKeys.lastObject ;
    ResponseRoot *root = dict.allValues.lastObject;
    ArtistsContentViewController *artistsContentVC = [[ArtistsContentViewController alloc] initWithResponseRoot:root];
    artistsContentVC.title = title;
    return artistsContentVC;
}

//请求艺人信息
-(void) requestFromArtistName:(NSString*) name{
    NSURLRequest *request = [[RequestFactory new] createSearchWithText:name];
    [self dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *json = [self serializationDataWithResponse:response data:data error:error];
        if (json) {
            json = [json valueForKey:@"results"];

            NSMutableArray<NSDictionary<NSString*,ResponseRoot*>*> *list = [NSMutableArray array];
            [json enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                ResponseRoot *root = [ResponseRoot instanceWithDict:obj];
                NSDictionary *dict = @{(NSString*)key:root};

                //过滤多余的资源, 保留下面这4 种
                if ([key isEqualToString:@"artists"]  ||
                    [key isEqualToString:@"songs"]    ||
                    [key isEqualToString:@"albums"]   ||
                    [key isEqualToString:@"music-videos"]) {
                    [list addObject:dict];
                }
            }];
            self.results = list;

            //设置pageView 第一页 (下标0)
            dispatch_async(dispatch_get_main_queue(), ^{
                UIViewController *artistContentVC = [self viewControllerAtIndex:0];
                [self->_pageViewController setViewControllers:@[artistContentVC,]
                                                    direction:UIPageViewControllerNavigationDirectionForward
                                                     animated:YES
                                                   completion:nil];

                //设置分段控制器, 并选出一张图片, 设置到image中
                for (int i = 0; i < self.results.count; i++) {
                    NSDictionary<NSString*,ResponseRoot*> *dict = [self.results objectAtIndex:i];
                    [self.segmentControl insertSegmentWithTitle:dict.allKeys.firstObject atIndex:i animated:YES];
                    if ([dict valueForKey:@"albums"]) {
                        Resource *resource = [dict valueForKey:@"albums"].data.firstObject;
                        Artwork *artwork = [Artwork instanceWithDict:[resource.attributes valueForKey:@"artwork"]];
                        [self showImageToView:self.imageView withImageURL:artwork.url cacheToMemory:YES];
                    }
                }
                [self.segmentControl setSelectedSegmentIndex:0];


            });
        }
    }];
}


#pragma mark - target active
/**选中分段, 切换视图*/
-(void)valueChange:(UISegmentedControl*) segmented{

    NSUInteger index = segmented.selectedSegmentIndex;
    UIViewController *selectedVC = [self viewControllerAtIndex:index];

    //判断方向
    if (index > self.currentIndex) {
        [self.pageViewController setViewControllers:@[selectedVC,]
                                           direction:UIPageViewControllerNavigationDirectionForward
                                            animated:YES
                                          completion:nil];

        self.currentIndex = index;
    }
    if (index < self.currentIndex){
        [self.pageViewController setViewControllers:@[selectedVC]
                                          direction:UIPageViewControllerNavigationDirectionReverse
                                           animated:YES
                                         completion:nil];
        self.currentIndex = index;
    }
}

#pragma mark getter
-(UIImageView *)imageView{
    if (!_imageView) {
        CGFloat w = CGRectGetWidth(self.view.frame);
        CGFloat h = w;
        CGRect frame = CGRectMake(0, 0, w, h);
        _imageView = [[UIImageView alloc] initWithFrame:frame];
    }
    return _imageView;
}

-(UIScrollView *)scrollView{
    if (!_scrollView) {

        //frame
        CGRect frame = [UIScreen mainScreen].bounds;
        CGFloat y = CGRectGetHeight(self.navigationController.navigationBar.frame)+20;
        frame.origin.y = y;
        _scrollView = [[UIScrollView alloc] initWithFrame:frame];

        _scrollView.delegate = self;

        //content size
        CGSize size = frame.size;
        size.height += CGRectGetHeight(self.imageView.frame)+64;
        [_scrollView setContentSize:size];
    }
    return _scrollView;
}
-(UIView *)contentView{
    if (!_contentView) {

        CGFloat y = CGRectGetMaxY(self.imageView.frame)-(self.topOffset);
        CGRect rect = CGRectMake(0, y, CGRectGetWidth(self.scrollView.bounds), CGRectGetHeight(self.scrollView.bounds));
        _contentView = [[UIView alloc] initWithFrame:rect];
        [_contentView setBackgroundColor:UIColor.whiteColor];

    }
    return _contentView;
}

-(UISegmentedControl *)segmentControl{
    if (!_segmentControl) {
        CGRect frame = CGRectMake(0, 0, 414, 44);
         _segmentControl = [[UISegmentedControl alloc] initWithFrame:frame];
        [_segmentControl setBackgroundColor:UIColor.whiteColor];
        [_segmentControl addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventValueChanged];
    }
    return _segmentControl;
}

-(UIPageViewController *)pageViewController{
    if (!_pageViewController) {
        _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                              navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                            options:nil];
        _pageViewController.delegate =self;
        _pageViewController.dataSource = self;

        //分段控制器下方  //(用高度,不用Y值, 因为滚动到上部时,将分段控制器移动到self.view 中,)
        CGFloat y = CGRectGetHeight(self.segmentControl.frame);
        CGRect frame = self.contentView.frame;
        frame.origin.y = y;
        _pageViewController.view.frame = frame;
    }
    return _pageViewController;
}



@end
