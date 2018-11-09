//
//  TodayCollectionViewController.m
//  MMusic
//

//  Copyright © 2017年 com.😈. All rights reserved.
//

//frameworks

#import <UIImageView+WebCache.h>
#import <MJRefresh.h>
#import <Masonry.h>

//controller
#import "RecommendationViewController.h"
#import "DetailViewController.h"

//view
#import "TodaySectionView.h"
#import "ResourceCell.h"
#import "ResourceCell_V2.h"

//model
#import "Resource.h"
#import "Artwork.h"
#import "Playlist.h"
#import "Album.h"


#import "DataStoreKit.h"

@interface RecommendationViewController()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDataSourcePrefetching>


@property(nonatomic, strong) UIActivityIndicatorView *activityView;     //内容加载指示器
@property(nonatomic, strong) UICollectionView *collectionView;          //内容ui

//json 结构
@property(nonatomic, strong) NSArray<NSDictionary<NSString*,NSArray<Resource*>*>*> *allData;
@end


@implementation RecommendationViewController
//reuse  identifier
static NSString *const sectionIdentifier = @"sectionView";
static NSString *const cellIdentifier = @"resourceCell";

#pragma mark - cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:self.collectionView];

    //数据加载指示器
    [self.collectionView addSubview:self.activityView];

    [self requestData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma  mark - 请求数据 和解析JSON
- (void)requestData {

    //加载数据
    [DataStore.new requestDefaultRecommendationWithCompletion:^(NSArray<NSDictionary<NSString *,NSArray<Resource *> *> *> * _Nonnull array) {
        dispatch_async(dispatch_get_main_queue(), ^{

            self.allData = array;

            [self.activityView stopAnimating];
            [self.activityView removeFromSuperview];
            self.activityView = nil;

            [self.collectionView reloadData];
            [self.collectionView.mj_header endRefreshing];
        });
    }];
}

#pragma mark - <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.allData.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return  [self.allData objectAtIndex:section].allValues.firstObject.count;
}

//cell
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    NSDictionary<NSString*,NSArray<Resource*>*> *dict = [self.allData objectAtIndex:indexPath.section]; //节数据
    Resource* resource = [dict.allValues.firstObject objectAtIndex:indexPath.row];                      //row数据

    //dequeue cell
    ResourceCell_V2 *cell;
    cell = (ResourceCell_V2*)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    //只有专辑和歌单两种类型;
    if ([resource.type isEqualToString:@"albums"]) {
        Album *album = [Album instanceWithResource:resource];
        cell.album = album;
    }else{
        Playlist *playlist = [Playlist instanceWithResource:resource];
        cell.playlists = playlist;
    }
    return cell;
}

//头尾
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    //节头
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        NSString *title = [self.allData objectAtIndex:indexPath.section].allKeys.firstObject;
        TodaySectionView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                      withReuseIdentifier:sectionIdentifier
                                                                             forIndexPath:indexPath];
        [header.titleLabel setText:title];
        return header;
    }
    return nil;
}

#pragma mark - UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

}

#pragma mark - UICollectionViewDataSourcePrefetching  预取数据
- (void)collectionView:(UICollectionView *)collectionView prefetchItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths{

}

#pragma mark - getter
-(UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = UICollectionViewFlowLayout.new;
        layout.scrollDirection =  UICollectionViewScrollDirectionVertical;

        //两列
        CGFloat spacing = 8.0f;
        CGFloat cw = (CGRectGetWidth(self.view.frame) - spacing*3)/2;
        CGFloat ch = cw+32;
        [layout setItemSize:CGSizeMake(cw, ch)];

        [layout setMinimumLineSpacing:spacing*2];
        [layout setMinimumInteritemSpacing:spacing];
        [layout setSectionInset:UIEdgeInsetsMake(0, spacing, spacing, spacing)]; //cell 与头尾间距

        //section size
        CGFloat h = 44.0f;
        CGFloat w = CGRectGetWidth(self.view.bounds);
        [layout setHeaderReferenceSize:CGSizeMake(w, h)];

        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        [_collectionView registerClass:ResourceCell_V2.class forCellWithReuseIdentifier:cellIdentifier];
        [_collectionView registerClass:TodaySectionView.class
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:sectionIdentifier];

        _collectionView.backgroundColor = UIColor.whiteColor;
        _collectionView.dataSource = self;
        _collectionView.delegate  = self;

        //绑定下拉刷新 事件
        _collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            UIImpactFeedbackGenerator *impact = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleHeavy];
            [impact impactOccurred];
            [self requestData];
        }];

        [_collectionView.mj_header setIgnoredScrollViewContentInsetTop:20]; //调整顶部距离
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

@end
