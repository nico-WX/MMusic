//
//  BorseViewController.m
//  MMusic
//
//  Created by Magician on 2018/4/26.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <Masonry.h>
#import <MJRefresh.h>

#import "BrowseViewController.h"
#import "ChartsPlaylistsCell.h"
#import "ScreeningViewController.h"
#import "SearchViewController.h"
#import "BrowseSectionHeaderView.h"
#import "RequestFactory.h"
#import "ResponseRoot.h"
#import "Resource.h"
#import "Artwork.h"

@interface BrowseViewController ()<UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
//搜索栏添加到导航栏, 搜索提示视图插入视图最上层.
@property(nonatomic, strong) SearchViewController *searchVC;

//刷选视图
@property(nonatomic, strong) UIView *screeningView;

//浏览内容
@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) NSArray<NSDictionary<NSString*,ResponseRoot*>*> *results;
@end

static const CGFloat row = 2.0f;                //cell 列数
static const CGFloat miniSpacing = 2.0f;        //cell 最小间距
static const CGFloat cellTitleHeight = 30.0f;   //cell title高度

//重用ID
static NSString *const cellID = @"cellReuseIdentifier";
static NSString *const sectionHeaderID = @"secionHeaderIdentifier";
@implementation BrowseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;

    //将搜索栏 添加到导航栏中, 搜索栏的提示视图添加到视图中
    [self addChildViewController:self.searchVC];
    [self.navigationController.navigationBar addSubview:self.searchVC.serachBar];
    [self.view addSubview:self.searchVC.view];

    //刷选视图插入 搜索视图下层
    [self.view addSubview:self.screeningView];
    [self.view insertSubview:self.screeningView belowSubview:self.searchVC.view];

    //集合视图插入搜索视图下层
    [self.view insertSubview:self.collectionView belowSubview:self.searchVC.view];


    NSString *str = @"粤语";
    [self requestDataWithTerms:str];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    //不隐藏(搜索时, 会隐藏搜索框)
    [self.searchVC.serachBar setHidden:NO];

    //layout
    __weak typeof(self) weakSelf = self;
    UIView *superview = self.navigationController.navigationBar;
    [self.searchVC.serachBar mas_makeConstraints:^(MASConstraintMaker *make) {
        UIEdgeInsets padding = UIEdgeInsetsMake(0, 0, 0, 0);
        make.edges.mas_equalTo(superview).with.insets(padding);
    }];

    superview = self.view;
    //对齐导航栏下方
    [self.screeningView mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat w = CGRectGetWidth(superview.bounds);
        CGFloat h= 44.0f;
        CGFloat navMaxY = CGRectGetMaxY(weakSelf.navigationController.navigationBar.frame);
        make.top.mas_equalTo(superview.mas_top).offset(navMaxY);
        make.left.mas_equalTo(superview.mas_left);
        make.size.mas_equalTo(CGSizeMake(w, h));
    }];

    //对齐刷选视图下方
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.screeningView.mas_bottom);
        make.left.mas_equalTo(superview.mas_left).offset(miniSpacing);
        make.right.mas_equalTo(superview.mas_right).offset(-miniSpacing);
        CGFloat tabBarMinY = CGRectGetMinY(weakSelf.tabBarController.tabBar.frame);
        make.bottom.mas_equalTo(tabBarMinY).offset(-miniSpacing);
    }];
}

#pragma mark - UICollectionView DataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return self.results.count;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.results objectAtIndex:section].allValues.firstObject.data.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ChartsPlaylistsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    ResponseRoot *root = [self.results objectAtIndex:indexPath.section].allValues.firstObject;
    Resource *resource = [root.data objectAtIndex:indexPath.row];
    cell.titleLabel.text = [resource.attributes valueForKeyPath:@"name"];
    Artwork *artwork = [Artwork instanceWithDict:[resource.attributes valueForKeyPath:@"artwork"]];
    [self showImageToView:cell.artworkView withImageURL:artwork.url cacheToMemory:YES];
    cell.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:0.9];

    return cell;
}
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    BrowseSectionHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                         withReuseIdentifier:sectionHeaderID
                                                                                forIndexPath:indexPath];
    if (header) {
        header.backgroundColor = UIColor.whiteColor;
        NSDictionary *dict = [self.results objectAtIndex:indexPath.section];

        //节头title
        NSString *text = dict.allKeys.firstObject;
        header.titleLable.text = text;

        //有下一页,显示按钮, 无下一页隐藏
        ResponseRoot *root = [dict allValues].firstObject;
        if (!root.next) {
            [header.moreButton setHidden:YES];
        }else{
            [header.moreButton setHidden:NO];
            [header.moreButton handleControlEvent:UIControlEventTouchUpInside withBlock:^{
                [self loadNextPageWithHref:root.next];
            }];
        }
        return header;
    }
    return nil;
}

#pragma mark - UICollectionView Delegate
#pragma mark - UICollectionView DelegateFlowLayout
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    CGFloat w = CGRectGetWidth(collectionView.bounds);
    CGFloat h = 44.0f;
    return CGSizeMake(w, h);
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat w = CGRectGetWidth(collectionView.bounds);
    w = w - (row+1)*miniSpacing;    //减去列的间距
    w = w/row;  //cell 宽度

    CGFloat h = w + cellTitleHeight; //增加高度  放Title
    return CGSizeMake(w, h);
}

#pragma mark - 数据请求 和解析

-(void)requestDataWithTerms:(NSString*) terms{
    NSURLRequest *request = [RequestFactory.new createSearchWithText:terms types:SearchPlaylistsType];
    [self dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *json = [self serializationDataWithResponse:response data:data error:error];
        self.results = [self serializationJSON:json];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    }];
}
-(NSArray<NSDictionary<NSString*,ResponseRoot*>*> *)serializationJSON:(NSDictionary*) json{
    json = [json objectForKey:@"results"];

    NSMutableArray *tempArray = NSMutableArray.new;
    [json enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        ResponseRoot *root = [ResponseRoot instanceWithDict:obj];
        [tempArray addObject:@{(NSString*)key:root}];
    }];
    return tempArray;
}
-(void) loadNextPageWithHref:(NSString*) href{
    Log(@"href=%@",href);
    NSURLRequest *request = [RequestFactory.new createRequestWithHerf:(NSString *)href];
    [self dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *json = [self serializationDataWithResponse:response data:data error:error];
        if (json != NULL) {
            NSArray<NSDictionary<NSString*,ResponseRoot*>*> *temp = [self serializationJSON:json];
            Log(@"temp=%@",json);
            //返回的数据  查找对应的对象(通过Key), 添加到对象中
            [temp enumerateObjectsUsingBlock:^(NSDictionary<NSString *,ResponseRoot *> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, ResponseRoot * _Nonnull obj, BOOL * _Nonnull stop) {
                    //查找对应的数据
                    for ( NSDictionary<NSString*,ResponseRoot*> *dict in self.results) {
                        if ([dict valueForKey:key]) {
                            ResponseRoot *root = [dict objectForKey:key];
                            //f覆盖下一页
                            root.next = obj.next ? obj.next : NULL;
                            //添加数据
                            root.data = [root.data arrayByAddingObjectsFromArray:obj.data];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.collectionView reloadData];
                            });
                        }
                    }
                }];
            }];
        }
    }];
}

#pragma mark - getter
- (SearchViewController *)searchVC{
    if (!_searchVC) {
        _searchVC = SearchViewController.new;
    }
    return _searchVC;
}

-(UICollectionView *)collectionView{
    if(!_collectionView) {
        UICollectionViewFlowLayout *layout = UICollectionViewFlowLayout.new;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.minimumInteritemSpacing = miniSpacing;
        layout.minimumLineSpacing = miniSpacing;

        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        [_collectionView registerClass:ChartsPlaylistsCell.class forCellWithReuseIdentifier:cellID];
        //头
        [_collectionView registerClass:BrowseSectionHeaderView.class forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:sectionHeaderID];
        _collectionView.backgroundColor = UIColor.whiteColor;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;

        //上拉加载更多
        _collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{

        }];
    }
    return _collectionView;
}

-(UIView *)screeningView{
    if (!_screeningView) {
        _screeningView = UIView.new;
        _screeningView.backgroundColor = UIColor.redColor;
    }
    return _screeningView;
}

@end
