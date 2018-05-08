//
//  TodayCollectionViewController.m
//  MMusic
//
//  Created by Magician on 2017/12/26.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import <UIImageView+WebCache.h>
#import <MJRefresh.h>
#import <Masonry.h>

#import "TodayCollectionViewController.h"
#import "TodayCell.h"
#import "HeadCell.h"
#import "DetailViewController.h"
#import "SearchViewController.h"

#import "PersonalizedRequestFactory.h"
#import "Resource.h"
#import "Artwork.h"
#import "Playlist.h"
#import "Album.h"

@interface TodayCollectionViewController()<UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property(nonatomic, strong) UIActivityIndicatorView *activityView; //加载指示器
@property(nonatomic, strong) NSArray<NSString*> *titles;            //节title
@property(nonatomic, strong) NSArray<NSArray<Resource*>*> *resources; //所有资源对象
@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) SearchViewController *searchVC;
@end


static const CGFloat row = 2.0f;
static const CGFloat miniSpacing = 2.0f;

@implementation TodayCollectionViewController
//reuse  identifier
static NSString *const sectionIdentifier = @"sectionView";
static NSString *const cellIdentifier = @"todayCell";

#pragma mark - cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.whiteColor;
    [self requestData];

    //将搜索栏 添加到导航栏中, 搜索栏的提示视图添加到视图中
    [self addChildViewController:self.searchVC];
    [self.navigationController.navigationBar addSubview:self.searchVC.serachBar];
    [self.view addSubview:self.searchVC.view];

    //添加 到父视图  并约束
    [self.view insertSubview:self.collectionView belowSubview:self.searchVC.view];

    //添加加载指示器
    [self.view addSubview:self.activityView];

    //设置刷新
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self requestData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    //不隐藏(搜索/显示详细时, 会隐藏搜索框)
    [self.searchVC.serachBar setHidden:NO];

    //layout
    __weak typeof(self) weakSelf = self;
    UIView *superview = self.navigationController.navigationBar;
    [self.searchVC.serachBar mas_makeConstraints:^(MASConstraintMaker *make) {
        UIEdgeInsets padding = UIEdgeInsetsMake(0, 0, 0, 0);
        make.edges.mas_equalTo(superview).with.insets(padding);
    }];

    superview = self.view;
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        //减去导航栏/状态栏 及tabbar 高度
        CGFloat tabBatH = CGRectGetHeight(weakSelf.tabBarController.tabBar.frame);
        CGFloat y = CGRectGetMaxY(weakSelf.navigationController.navigationBar.frame);
        UIEdgeInsets insets = UIEdgeInsetsMake(miniSpacing+y, miniSpacing, miniSpacing+tabBatH, miniSpacing);
        make.edges.mas_equalTo(superview).with.insets(insets);
    }];
}

#pragma  mark - 请求数据
- (void)requestData {
    //个人数据请求
    PersonalizedRequestFactory *fac = [PersonalizedRequestFactory new];
    NSURLRequest *request = [fac createRequestWithType:PersonalizedDefaultRecommendationsType resourceIds:@[]];
    [self dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary * json= [self serializationDataWithResponse:response data:data error:error];
        if (json) {
            NSMutableArray *tempList = NSMutableArray.new;  //所有数据临时集合
            NSMutableArray *titleList = NSMutableArray.new; //临时节title 集合

            for (NSDictionary *subJSON in [json objectForKey:@"data"]) {
                NSString *title = [subJSON valueForKeyPath:@"attributes.title.stringForDisplay"];
                if (!title) {
                    NSArray *list = [subJSON valueForKeyPath:@"relationships.contents.data"];
                    title = [list.firstObject valueForKeyPath:@"attributes.curatorName"];
                }
                [titleList addObject:title];
                //解析
                [tempList addObject:[self serializationJSON:subJSON]];
            }

            //所有数据解析完成, 设置数据
            self.resources = tempList;
            self.titles = titleList;
            //刷新UI
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.activityView stopAnimating];

                [self.collectionView reloadData];
                [self.collectionView.mj_header endRefreshing];
            });
        }
    }];
}
/**解析JSON 数据*/
-(NSArray<Resource*>*) serializationJSON:(NSDictionary*) json{
    NSMutableArray<Resource*> *sectionList = [NSMutableArray array];  //节数据临时集合

    json = [json objectForKey:@"relationships"];
    NSDictionary *contents = [json objectForKey:@"contents"];  //如果这里有内容, 则不是组推荐, 没有值就是组推荐
    if (contents) {
        //非组推荐
        for (NSDictionary *sourceDict in [contents objectForKey:@"data"]) {
            Resource *resouce = [Resource instanceWithDict:sourceDict];
            [sectionList addObject:resouce];
        }
    }else{
        //组推荐
        NSDictionary *recommendations = [json objectForKey:@"recommendations"];
        if (recommendations) {
            for (NSDictionary *subJSON  in [recommendations objectForKey:@"data"]) {
                //递归
                NSArray *temp =[self serializationJSON: subJSON];
                //数据添加
                [sectionList addObjectsFromArray:temp];
            }
        }
    }
    return sectionList;
}

#pragma mark - <UICollectionViewDataSource>
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return self.resources.count;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.resources objectAtIndex:section].count;
}

//cell
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TodayCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    // Configure the cell

    Resource* resource = [[self.resources objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];

    //设置封面
    if ([resource respondsToSelector:@selector(attributes)]) {
        Artwork *artwork = [Artwork instanceWithDict:[resource.attributes valueForKey:@"artwork"]];
        [self showImageToView:cell.artworkView withImageURL:artwork.url cacheToMemory:YES];
    }
    return cell;
}

//头尾
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    //节头
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        NSString *title = [self.titles objectAtIndex:indexPath.section];
        HeadCell *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                            withReuseIdentifier:sectionIdentifier
                                                                forIndexPath:indexPath];
        [header.titleLabel setText:title];
        header.backgroundColor = collectionView.backgroundColor;
        return header;
    }
    return nil;
}

#pragma mark - UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    Resource *obj = [[self.resources objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    DetailViewController *detailVC = [[DetailViewController alloc] initWithResource:obj];
    [self.searchVC.serachBar setHidden:YES];
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - UICollectionViewDelegateFlowLayout
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat w = CGRectGetWidth(collectionView.bounds);
    w = w-(row+1)*miniSpacing;  //减去间距
    w = w/row;                  //单个cell 宽度
    CGFloat h = w ;
    return CGSizeMake(w, h);
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    CGFloat h = 44.0f;
    CGFloat w = CGRectGetWidth(collectionView.bounds);
    return CGSizeMake(w, h);
}

#pragma mark - getter
-(UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = UICollectionViewFlowLayout.new;
        layout.scrollDirection =  UICollectionViewScrollDirectionVertical;
        layout.sectionHeadersPinToVisibleBounds = YES;
        layout.minimumLineSpacing = miniSpacing;
        layout.minimumInteritemSpacing = miniSpacing;

        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        [_collectionView registerClass:[TodayCell class] forCellWithReuseIdentifier:cellIdentifier];
        [_collectionView registerClass:[HeadCell class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:sectionIdentifier];
        _collectionView.backgroundColor = UIColor.whiteColor;
        _collectionView.dataSource = self;
        _collectionView.delegate  = self;
    }
    return _collectionView;
}
- (UIActivityIndicatorView *)activityView{
    if (!_activityView) {
        _activityView = [[UIActivityIndicatorView alloc] initWithFrame:self.collectionView.frame];
        [_activityView setHidesWhenStopped:YES];
        [_activityView setColor:[UIColor lightGrayColor]];
        [_activityView setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.96 alpha:0.9]];
        [_activityView startAnimating];
    }
    return _activityView;
}

-(SearchViewController *)searchVC{
    if (!_searchVC) {
        _searchVC = SearchViewController.new;
    }
    return _searchVC;
}
@end
