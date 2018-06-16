//
//  ResultsViewController.m
//  MMusic
//
//  Created by Magician on 2018/4/9.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import <Masonry.h>

#import "ResultsViewController.h"
#import "ResultsContentViewController.h"
#import "ClassifyCell.h"

#import "NSObject+Tool.h"
#import "RequestFactory.h"

#import "ResponseRoot.h"

#pragma mark - property
@interface ResultsViewController ()<UIPageViewControllerDelegate,UIPageViewControllerDataSource,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
//记录当前显示的分页, 处理pageViewController 滚动导航方向
@property(nonatomic, assign) NSUInteger currentIndex;
//结果分类指示视图
@property(nonatomic, strong) UICollectionView *classifyView;

//分页控制器
@property(nonatomic, strong) UIPageViewController *pageViewController;

//初始化搜索文本
@property(nonatomic, strong, readonly) NSString *searchText;
//数据
@property(nonatomic, strong) NSArray<NSDictionary<NSString*,ResponseRoot*> *> *results;
//创建过的视图控制器, 避免多次创建
@property(nonatomic, strong)NSMutableArray<ResultsContentViewController*> *vcArray;
@end

static NSString * const cellID = @"colletionCellReuseId";
@implementation ResultsViewController

#pragma mark - init
- (instancetype)initWithSearchText:(NSString *)searchText{
    if (self = [super init]) {
        _searchText = searchText;
    }
    return self;
}

#pragma mark - cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     self.title = self.searchText;

    /**
     1.搜索到结果后, 通过分页控制器显示内容分页,
     */

    self.view.backgroundColor = UIColor.whiteColor;
    [self requestDataFromSearchText:self.searchText];

    //搜索分类视图
    [self.view addSubview:self.classifyView];

    //分页控制器
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    //布局
    UIView *superview = self.view;
    __weak typeof(self) weakSelf = self;
    UIEdgeInsets padding = UIEdgeInsetsMake(1, 4, 1, 4);
    [self.pageViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.classifyView.mas_bottom).offset(padding.top);
        make.left.mas_equalTo(superview.mas_left).offset(padding.left);
        make.right.mas_equalTo(superview.mas_right).offset(-padding.right);

        CGFloat tabBarH = CGRectGetHeight(weakSelf.tabBarController.tabBar.frame);
        make.bottom.mas_equalTo(superview.mas_bottom).offset(-(tabBarH+padding.bottom));
    }];
}


#pragma mark - Helper
-(void) requestDataFromSearchText:(NSString *) searchText{
    NSURLRequest *request = [[RequestFactory new] createSearchWithText:searchText];
    [self dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *json = [self serializationDataWithResponse:response data:data error:error];
        json = [json valueForKey:@"results"];

        //检查结果返回空结果字典
        if (json.allKeys.count != 0)  {

            NSMutableArray *resultsList = [NSMutableArray array];
            //解析字典
            [json enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                ResponseRoot *root = [ResponseRoot instanceWithDict:obj];
                [resultsList addObject:@{(NSString*)key:root}];
            }];
            self.results = resultsList;

            //数据完成处理  设置视图
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.classifyView reloadData];

                //选中第一个分类的第一个cell
                self.currentIndex = 0;
                [self.classifyView selectItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0]
                                                animated:YES
                                          scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];

                //pageView 显示第一个内容视图
                ResultsContentViewController *vc = (ResultsContentViewController*)[self viewControllerAtIndex:self.currentIndex];
                [self->_pageViewController setViewControllers:@[vc,]
                                                    direction:UIPageViewControllerNavigationDirectionForward
                                                     animated:YES
                                                   completion:nil];
            });

        }else{
            [self showHUDToMainWindowFromText:@"没有查找到数据"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });

        }
    }];
}

//返回控制器对应的下标
-(NSUInteger) indexOfViewController:(ResultsContentViewController*) viewController{
    NSUInteger index = 0;
    for (NSDictionary<NSString*,ResponseRoot*> *dict in self.results) {
        if (viewController.responseRoot == dict.allValues.firstObject) {
            index = [self.results indexOfObject:dict];
        }
    }
    return index;
}

//按下标, 获取控制器
-(UIViewController*) viewControllerAtIndex:(NSUInteger) index{
    //没有内容 , 或者大于内容数量  直接返回nil
    if (self.results.count == 0 || index > self.results.count) return nil;

    NSDictionary<NSString*,ResponseRoot*> *dict = [self.results objectAtIndex:index];
    NSString *title = [dict allKeys].firstObject;
    ResponseRoot *root = [dict allValues].firstObject;

    //查找创建过的VC
    for (ResultsContentViewController *vc in self.vcArray) {
        if (vc.responseRoot == root) {
            return vc;
        }
    }

    //数组中没有创建过的控制器, 创建新的,并添加到数组
    ResultsContentViewController *contentVC = [[ResultsContentViewController alloc] initWithResponseRoot:root];
    [contentVC setTitle:title];
    [self.vcArray addObject:contentVC];
    return contentVC;
}


#pragma mark - UIPageViewControllerDataSource
//返回左边控制器
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    ResultsContentViewController *resultsVC = (ResultsContentViewController*) viewController;

    NSUInteger index = [self indexOfViewController:resultsVC];
    if (index == 0 || index == NSNotFound) return nil;
    index--;
    return [self viewControllerAtIndex:index];
}

//返回右边控制器
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
     ResultsContentViewController *resultsVC = (ResultsContentViewController*) viewController;
    NSUInteger index = [self indexOfViewController:resultsVC];
    if (index== NSNotFound) return nil;

    index++;
    if (index==self.results.count) return nil;

    return [self viewControllerAtIndex:index];
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
            ResultsContentViewController *contentVC = pageViewController.viewControllers.lastObject;
            NSUInteger index = [self indexOfViewController:contentVC];

            [self.classifyView selectItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]
                                            animated:YES
                                      scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
        }
    }

}

#pragma mark - UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.results.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ClassifyCell *cell = (ClassifyCell*)[collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    NSDictionary<NSString*,ResponseRoot*> *dict = [self.results objectAtIndex:indexPath.row];
    [cell.titleLabel setText:dict.allKeys.firstObject];
    return cell;
}


#pragma mark - UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //滚动item居中
    [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];

    UIViewController *vc = [self viewControllerAtIndex:indexPath.row];

    //判断滚动方向, 选中的item 与当前控制器下标一致  不处理
    if (indexPath.row > self.currentIndex) {
        [self.pageViewController setViewControllers:@[vc,] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    }
    if (indexPath.row < self.currentIndex) {
        [self.pageViewController setViewControllers:@[vc,] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
    }

    self.currentIndex = indexPath.row;
}

#pragma mark - UICollectionDelegateFlowLayout
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{

    CGFloat w = CGRectGetWidth(self.view.frame);
    CGFloat h = 38.0f;

    CGFloat cellH = h-2;
    CGFloat cellW = 0;

    if (self.results && self.results.count > 4) {
        cellW = w/4;
    }else{
        cellW = w/self.results.count;
    }
    return CGSizeMake(cellW, cellH);
}


#pragma mark - getter
-(UIPageViewController *)pageViewController{
    if (!_pageViewController) {
        _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                              navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                            options:nil];
        _pageViewController.delegate =self;
        _pageViewController.dataSource = self;
    }
    return _pageViewController;
}

-(UICollectionView *)classifyView{
    if (!_classifyView) {
        //colle frame
        CGFloat x = 0;
        CGFloat y = CGRectGetMaxY(self.navigationController.navigationBar.frame);
        CGFloat w = CGRectGetWidth(self.view.frame);
        CGFloat h = 38.0f;
        CGRect frame = CGRectMake(x, y, w, h);

        //layout
        UICollectionViewFlowLayout *layout = UICollectionViewFlowLayout.new;
        [layout setMinimumInteritemSpacing:1];
        [layout setMinimumLineSpacing:1];
        [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];

        //collectionView
        _classifyView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
        _classifyView.delegate = self;
        _classifyView.dataSource = self;
        [_classifyView registerClass:ClassifyCell.class forCellWithReuseIdentifier:cellID];
        [_classifyView setBackgroundColor:UIColor.whiteColor];
        [_classifyView setShowsHorizontalScrollIndicator:NO];

        _classifyView.layer.borderColor = UIColor.grayColor.CGColor;
        _classifyView.layer.borderWidth = 0.5;

    }
    return _classifyView;
}
-(NSMutableArray<ResultsContentViewController *> *)vcArray{
    if (!_vcArray) {
        _vcArray = [NSMutableArray array];
    }
    return _vcArray;
}

@end
