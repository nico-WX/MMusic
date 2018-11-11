//
//  BorseViewController.m
//  MMusic
//
//  Created by Magician on 2018/4/26.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <Masonry.h>
#import <MJRefresh.h>

//controller
#import "BrowseViewController.h"
#import "ScreeningViewController.h"
#import "ContentViewController.h"

//view
#import "ScreeningCell.h"

//tool model
#import "ModelController.h"
#import "ResponseRoot.h"
#import "Resource.h"
#import "Artwork.h"

@interface BrowseViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIScrollViewDelegate>
//导航栏中间按钮
@property(nonatomic, strong) UIButton *screeningButton;
//中间按钮  ("pop"视图)
@property(nonatomic, strong) ScreeningViewController *screeningVC;
//内容分类滚动视图(top)
@property(nonatomic, strong) UICollectionView *typesView;
//内容滚动视图
@property(nonatomic, strong) UIScrollView *scrollView;
//视图控制器 模型
@property(nonatomic, strong) ModelController *modelCtr;
//子控制器数组
@property(nonatomic, strong) NSArray<UIViewController*> *contentVCs;
//all data
@property(nonatomic, strong) NSArray<NSDictionary<NSString*,ResponseRoot*>*> *results;  //刷选搜索到的所有数据
@end

static const CGFloat miniSpacing = 2.0f;
static const CGFloat row =  4;
static NSString *const typesCellID = @"typesCellReuseIdentifier";
@implementation BrowseViewController

#pragma mark - cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;

    //分类视图
    self.navigationItem.titleView = self.screeningButton;
    [self.view addSubview:self.screeningVC.view];

    //资源类型  及内容视图
    [self.view insertSubview:self.typesView belowSubview:self.screeningVC.view];
    [self.view insertSubview:self.scrollView belowSubview:self.screeningVC.view];

    self.screeningVC.selectedItem(@"国语");

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

    //当前正在显示刷选视图 转到其他视图控制器
    if (self.screeningButton.isSelected == YES) {
        [self showScreening:self.screeningButton];  //隐藏视图
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];


    //布局
    __weak typeof(self) weakSelf = self;
    UIView *superview = self.view;
    UIEdgeInsets padding = UIEdgeInsetsMake(2, 2, 2, 2);
    [self.typesView mas_makeConstraints:^(MASConstraintMaker *make) {
        //top 对齐导航栏下方
        make.top.mas_equalTo(superview.mas_top).offset(CGRectGetMaxY(weakSelf.navigationController.navigationBar.frame));
        make.left.mas_equalTo(superview.mas_left).offset(padding.left);
        make.right.mas_equalTo(superview.mas_right).offset(-padding.right);
        make.height.mas_equalTo(44.0f);
    }];

    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.typesView.mas_bottom).offset(padding.top);
        make.left.mas_equalTo(superview.mas_left);
        make.right.mas_equalTo(superview.mas_right);
        //tabBar H
        CGFloat tabBarH = CGRectGetHeight(self.tabBarController.tabBar.frame);
        make.bottom.mas_equalTo(superview.mas_bottom).offset(-tabBarH);
    }];
}

#pragma mark - 数据请求 和解析
/**
 请求对应的数据
 @param terms 搜索文本
 */
-(void)requestDataWithTerms:(NSString*) terms{
    [[MusicKit new].catalog searchForTerm:terms callBack:^(NSDictionary *json, NSHTTPURLResponse *response) {
        self.results = [self serializationJSON:json];
        //更新UI 滚动内容大小 等
        dispatch_async(dispatch_get_main_queue(), ^{
            self.modelCtr = [[ModelController alloc] initWithData:self.results];    //覆盖模型控制器
            CGFloat w = CGRectGetWidth(self.view.bounds) * self.results.count;
            CGFloat h = CGRectGetHeight(self.scrollView.bounds);
            [self.scrollView setContentSize:CGSizeMake(w, h)];
            [self.typesView reloadData];
            //选中第一个 回滚到初始位置
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.typesView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
        });
    }];
}

/**
 解析JSON数据
 @param json JSON字典
 @return 解析完成的模型数据
 */
-(NSArray<NSDictionary<NSString*,ResponseRoot*>*> *)serializationJSON:(NSDictionary*) json{
    json = [json objectForKey:@"results"];
    NSMutableArray *tempArray = NSMutableArray.new;
    [json enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        //不要artists
        if (![(NSString*)key isEqualToString:@"artists"]) {
            ResponseRoot *root = [ResponseRoot instanceWithDict:obj];
            [tempArray addObject:@{(NSString*)key:root}];
        }
    }];
    return tempArray;
}

/**
 加载下一页数据
 @param href 数据子路径
 */
-(void) loadNextPageWithHref:(NSString*) href{
    NSURLRequest *request = [self createRequestWithHref:href];
    [self dataTaskWithRequest:request handler:^(NSDictionary *json, NSHTTPURLResponse *response) {
        if (json != NULL) {
            NSArray<NSDictionary<NSString*,ResponseRoot*>*> *temp = [self serializationJSON:json];
            //返回的数据  查找对应的对象(通过Key), 添加到对象中
            [temp enumerateObjectsUsingBlock:^(NSDictionary<NSString *,ResponseRoot *> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, ResponseRoot * _Nonnull obj, BOOL * _Nonnull stop) {
                    //查找对应的数据
                    for ( NSDictionary<NSString*,ResponseRoot*> *dict in self.results) {
                        if ([dict valueForKey:key]) {
                            [dict objectForKey:key].next = obj.next;
                            [dict objectForKey:key].data = [[dict objectForKey:key].data arrayByAddingObjectsFromArray:obj.data];
                            dispatch_async(dispatch_get_main_queue(), ^{
                            });
                        }
                    }
                }];
            }];
        }
    }];
}

#pragma mark - UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.results.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ScreeningCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:typesCellID forIndexPath:indexPath];
    cell.nameLable.text = [self.results objectAtIndex:indexPath.row].allKeys.firstObject;
    return cell;
}
#pragma mark - UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView == self.typesView) {
        [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];

        //计算滚动偏移量 X轴
        CGRect rect = self.view.bounds;
        CGFloat x = CGRectGetWidth(rect)*indexPath.row;
        CGFloat w = CGRectGetWidth(rect);
        CGFloat h = CGRectGetHeight(rect);
        CGRect visibleRect = CGRectMake(x, 0, w, h);
        [self.scrollView scrollRectToVisible:visibleRect animated:YES];
    }
}
#pragma mark - UICollectionViewDelegateFlowLayout
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat h = CGRectGetHeight(collectionView.bounds);
    CGFloat w = CGRectGetWidth(collectionView.bounds);
    w = w -(row+1)*miniSpacing;
    w = w/row;
    return CGSizeMake(w, h);
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView == self.scrollView) {

        CGFloat x = scrollView.contentOffset.x;
        CGFloat w = CGRectGetWidth(self.view.bounds);
        NSUInteger index = x/w;

        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.typesView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    }
}

#pragma mark - Target Active
/**
 显示分类视图
 @param button 按钮对象
 */
-(void) showScreening:(UIButton*) button{
    NSTimeInterval durarion = 0.7;
    CGRect rect = self.screeningVC.view.frame;
    if (button.isSelected) {
        button.selected = NO;
        rect.size.height = 0;
        [UIView animateWithDuration:durarion animations:^{
            self.screeningVC.view.frame = rect;
        }];
    }else{
        button.selected = YES;
        rect.size.height = 400;
        [UIView animateWithDuration:2 animations:^{
            self.screeningVC.view.frame = rect;
        }];
    }
}
#pragma mark - getter
-(UICollectionView *)typesView{
    if (!_typesView) {
        UICollectionViewFlowLayout *layout = UICollectionViewFlowLayout.new;
        [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        layout.minimumInteritemSpacing = miniSpacing;

        _typesView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_typesView registerClass:ScreeningCell.class forCellWithReuseIdentifier:typesCellID];
        _typesView.delegate = self;
        _typesView.dataSource = self;
        _typesView.backgroundColor = UIColor.whiteColor;

    }
    return _typesView;
}
- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = UIScrollView.new;
        [_scrollView setPagingEnabled:YES];
        _scrollView.delegate = self;
    }
    return _scrollView;
}

-(UIButton *)screeningButton{
    if (!_screeningButton) {
        _screeningButton = UIButton.new;
        [_screeningButton setTitle:@"分类▼" forState:UIControlStateNormal];
        [_screeningButton setTitle:@"分类▲" forState:UIControlStateSelected];
        [_screeningButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [_screeningButton setTitleColor:UIColor.blueColor forState:UIControlStateSelected];
        _screeningButton.frame = CGRectMake(0, 0, 100, CGRectGetHeight(self.navigationController.navigationBar.bounds));
        [_screeningButton addTarget:self action:@selector(showScreening:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _screeningButton;
}

-(ScreeningViewController *)screeningVC{
    if (!_screeningVC) {
        _screeningVC = [[ScreeningViewController alloc] init];
        CGFloat y = CGRectGetMaxY(self.navigationController.navigationBar.frame);
        CGFloat w = CGRectGetWidth(self.view.bounds);
        //其实高度0  隐藏
        _screeningVC.view.frame = CGRectMake(0, y, w, 0);
        _screeningVC.view.backgroundColor = UIColor.whiteColor;

        //选中取值
        __weak typeof(self) weakSelf = self;
        _screeningVC.selectedItem = ^(NSString *text) {
            [weakSelf.screeningButton setSelected:YES];
            [weakSelf showScreening:weakSelf.screeningButton];  //隐藏刷选视图
            [weakSelf requestDataWithTerms:text];

            NSString *title = [NSString stringWithFormat:@"%@▼",text];
            [weakSelf.screeningButton setTitle:title forState:UIControlStateNormal];
            weakSelf.screeningButton.titleLabel.text = [NSString stringWithFormat:@"%@▼",text];
        };
    }
    return _screeningVC;
}

#pragma mark - setter
-(void)setModelCtr:(ModelController *)modelCtr{
    if (_modelCtr != modelCtr) {
        _modelCtr = modelCtr;

        //有值  上次添加有控制器 全删除
        if (self.contentVCs) {
            for (UIViewController *vc in self.contentVCs) {
                [vc removeFromParentViewController];
                [vc.view removeFromSuperview];
            }
        }

        NSMutableArray *temp = NSMutableArray.new;
        __weak typeof(self) weakSelf = self;
        [self.results enumerateObjectsUsingBlock:^(NSDictionary<NSString *,ResponseRoot *> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

            ContentViewController *cVC = [modelCtr viewControllerAtIndex:idx];
            CGRect frame = weakSelf.scrollView.bounds;
            frame.origin.x = CGRectGetWidth(weakSelf.view.bounds)*idx;  // 沿x轴偏移 排列视图
            frame.size.height = frame.size.height-4;
            cVC.view.frame = frame;

            [self addChildViewController:cVC];
            [self.scrollView addSubview:cVC.view];

            [temp addObject:cVC];
        }];
        //覆盖
        self.contentVCs = temp;
    }
}



@end
