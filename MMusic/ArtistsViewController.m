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

@interface ArtistsViewController ()<UIPageViewControllerDelegate,UIPageViewControllerDataSource,UIScrollViewDelegate>

//基本 下拉  控件悬停
@property(nonatomic, strong) UIImageView *imageView;            //艺人照片
@property(nonatomic, strong) UIScrollView *scrollView;          //滚动视图
@property(nonatomic, strong) UIView *contentView;               //分页内容 和分段控制器 容器
@property(nonatomic, strong) UISegmentedControl *segmentControl;//分段控制器
@property(nonatomic, assign) CGFloat rate;                      //照片高/宽比
@property(nonatomic, assign) CGFloat topOffset;                 //顶部距离

@property(nonatomic, assign) NSUInteger currentIndex;           //当前选择的坐标


//数据
@property(nonatomic, strong)Resource *resource;

/**
 艺人相关数据
 */
@property(nonatomic, strong)NSArray<NSDictionary<NSString*,ResponseRoot*>*> *results;

//分页
@property(nonatomic, strong) UIPageViewController *pageViewController;

@end


@implementation ArtistsViewController

-(instancetype)initWithArtistResource:(Resource *)resource{
    if (self = [super init]) {
        _resource = resource;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.topOffset = CGRectGetHeight(self.navigationController.navigationBar.frame)+20;

    [self.view addSubview:self.imageView];
    [self.view addSubview:self.scrollView];

    [self.scrollView addSubview:self.contentView];

    [self.contentView addSubview:self.segmentControl];

    //分页控制器
    [self.contentView addSubview:self.pageViewController.view];
    [self addChildViewController:self.pageViewController];
    [self.pageViewController didMoveToParentViewController:self];

    //数据请求
    [self requestFromArtistResource:self.resource];


    self.view.backgroundColor = UIColor.whiteColor ;
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
-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed{
    if (completed) {
        if (finished) {
            UIViewController *contentVC = pageViewController.viewControllers.lastObject;
            NSUInteger index = [self indexForViewController:(ArtistsContentViewController*)contentVC];

            [self.segmentControl setSelectedSegmentIndex:index];
        }
    }
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{

    CGFloat y = scrollView.contentOffset.y;

    //悬停控件
    CGFloat imageH = CGRectGetHeight(self.imageView.frame);
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

/**
 数据请求
 @param resource 艺人Resource
 */
-(void)requestFromArtistResource:(Resource*) resource{

    NSString *name = [resource.attributes valueForKey:@"name"];
    NSURLRequest *request = [[RequestFactory new] createSearchWithText:name];
    [self dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *json = [self serializationDataWithResponse:response data:data error:error];
        json = [json valueForKey:@"results"];
        if (json) {
            NSMutableArray<NSDictionary<NSString*,ResponseRoot*>*> *list = [NSMutableArray array];
            NSMutableArray<NSString*> *titles = [NSMutableArray array];

            [json enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                ResponseRoot *root = [ResponseRoot instanceWithDict:obj];
                NSDictionary *dict = @{(NSString*)key:root};


                //过滤多余的资源
                if ([key isEqualToString:@"artists"]  ||
                    [key isEqualToString:@"songs"]    ||
                    [key isEqualToString:@"albums"]   ||
                    [key isEqualToString:@"music-videos"]) {
                    [list addObject:dict];
                    //设置分段控制器
                    [titles addObject:key];
                }
            }];
            self.results = list;

            //设置pageView 第一页
            dispatch_async(dispatch_get_main_queue(), ^{
                UIViewController *artistContentVC = [self viewControllerAtIndex:0];
                [self->_pageViewController setViewControllers:@[artistContentVC,]
                                                    direction:UIPageViewControllerNavigationDirectionForward
                                                     animated:YES
                                                   completion:nil];

                //设置分段控制器
                for (int i = 0; i<titles.count; i++) {
                    [self.segmentControl insertSegmentWithTitle:titles[i] atIndex:i animated:YES];
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
        UIImage *image = [UIImage imageNamed:@"FelixMittermeier.jpg"];
        _imageView = [[UIImageView alloc] initWithImage:image];

        CGSize imageSize = image.size;
        CGFloat rate = imageSize.height/imageSize.width;
        self.rate = rate;

        CGFloat w = CGRectGetWidth(self.view.bounds);
        CGFloat h = w *rate;

        [_imageView setFrame:CGRectMake(0, self.topOffset, w, h)];
    }
    return _imageView;
}

-(UIScrollView *)scrollView{
    if (!_scrollView) {

        //frame
        CGRect frame = [UIScreen mainScreen].bounds;
        CGFloat y = CGRectGetMinY(self.imageView.frame);
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
        [_contentView setBackgroundColor:UIColor.brownColor];
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

        //分段控制器下方
        _pageViewController.view.frame = ({
            CGRect frame = self.contentView.frame;
            frame.origin.y = CGRectGetMaxY(self.segmentControl.frame);
            frame;
        });

    }

    return _pageViewController;
}



@end
