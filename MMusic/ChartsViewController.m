//
//  ChartsViewController.m
//  MMusic
//
//  Created by Magician on 2018/4/24.
//  Copyright © 2018年 com.😈. All rights reserved.
//

//pod and system
#import <Masonry.h>
#import <MJRefresh.h>

//Controller
#import "ChartsViewController.h"

//view  and cell
#import "NewCardView.h"
#import "ChartsAlbumCell.h"
#import "ChartsPlaylistsCell.h"
#import "MusicVideoCell.h"
#import "ChartsSongCell.h"


//model and tool
//#import "RequestFactory.h"
#import "Chart.h"
#import "Resource.h"
#import "Album.h"
#import "Playlist.h"
#import "MusicVideo.h"
#import "Song.h"
#import "Artwork.h"

@interface ChartsViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property(nonatomic, strong) NSURLRequest *request;
//viwe
@property(nonatomic, strong) NewCardView *cardView;
//
@property(nonatomic, strong) UICollectionView *collectionView;

//data
@property(nonatomic) NSArray<Chart*> *results;
@end
static CGFloat const spacing = 2.0f;
static NSString *const cellId = @"cell reuse Identifier";
@implementation ChartsViewController

#pragma mark - init

-(instancetype)initWithChartsType:(ChartsType)type{
    if (self = [super init]) {
        _request = [[RequestFactory new] createChartWithChartType:type];
        _collectionView = [self collectionViewWithChartsType:type];
    }
    return self;
}



#pragma mark - cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;

    [self requestDataFromRequest:self.request];
    [self.view addSubview:self.cardView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    CGFloat y = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    CGFloat tabH = CGRectGetHeight(self.tabBarController.tabBar.frame);
    UIEdgeInsets padding = UIEdgeInsetsMake(y+4, 4, tabH+4, 4);
    UIView *superview = self.view;
    [self.cardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(superview).with.insets(padding);
    }];
}

#pragma mark - UICollectionView DataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return self.results.count;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.results objectAtIndex:section].data.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    NSDictionary *dict = [[self.results objectAtIndex:indexPath.section].data objectAtIndex:indexPath.row];
    Resource *resource = [Resource instanceWithDict:dict];

    if ([cell respondsToSelector:@selector(titleLabel)]) {
        cell.
    }

    return cell;
}


#pragma mark - UICollectionView Delegate

#pragma mark - UICollectionView Delegate FlowLayout
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];

    if ([cell isKindOfClass:ChartsAlbumCell.class]) {
        CGFloat w = (CGRectGetWidth(collectionView.bounds) - spacing*2)/2;
        CGFloat h = w+28; //28 为cell标题的高度
        return CGSizeMake(w, h);
    }
    if ([cell isKindOfClass:ChartsPlaylistsCell.class]) {
        CGFloat w = (CGRectGetWidth(collectionView.bounds) - spacing*2)/2;
        CGFloat h = w+28; //28 为cell标题的高度
        return CGSizeMake(w, h);
    }
    if ([cell isKindOfClass:ChartsMusicVideoCell.class]) {
        CGFloat w = CGRectGetWidth(collectionView.bounds);
        CGFloat h = w*0.75;
        return CGSizeMake(w, h);
    }
    if ([cell isKindOfClass:ChartsSongCell.class]) {
        CGFloat h = 44.0f;
        CGFloat w = CGRectGetWidth(collectionView.bounds);
        return CGSizeMake(w, h);
    }

    return CGSizeZero;
}

#pragma mark - 数据请求 和解析
-(void)requestDataFromRequest:(NSURLRequest*) request{
    [self dataTaskWithdRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error && data) {
            NSDictionary *json = [self serializationDataWithResponse:response data:data error:error];

            self.results = [self serializationJSON:json];
            //刷新
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
                [self.collectionView.mj_header endRefreshing];
            });
        }
    }];
}

/**加载下一页数据*/
-(void) loadNextPage:(NSString*) nextHref{
    if (nextHref != NULL) {
        NSURLRequest *request = [[RequestFactory new] createRequestWithHerf:nextHref];
        [self dataTaskWithdRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSDictionary *json =  [self serializationDataWithResponse:response data:data error:error];
            NSArray<Chart*> *temp = [self serializationJSON:json];

            //添加新的数据
            Chart *oldChart = self.results.firstObject;
            Chart *newChart = temp.firstObject;
            oldChart.next = newChart.next;
            oldChart.data = [oldChart.data arrayByAddingObjectsFromArray:newChart.data];

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
                [self.collectionView.mj_footer endRefreshing];
            });
        }];
    }
}
-(NSArray<Chart*>*) serializationJSON:(NSDictionary*) json{
    __block NSMutableArray *tempResults = NSMutableArray.new;
    if (json) {
        json = [json valueForKey:@"results"];
        [json enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull charts, BOOL * _Nonnull stop) {
            [(NSArray*)charts enumerateObjectsUsingBlock:^(id  _Nonnull chartDict, NSUInteger idx, BOOL * _Nonnull stop) {
                Chart *chart = [Chart instanceWithDict:chartDict];
                [tempResults addObject:chart];
                dispatch_async(dispatch_get_main_queue(), ^{
                    _cardView.titleLabel.text = chart.name;
                });
            }];
        }];
    }
    return tempResults;
}

#pragma mark - tool method
/**配置不同类型的cell 等*/
-(UICollectionView*) collectionViewWithChartsType:(ChartsType) type{
    UICollectionViewFlowLayout *layout = UICollectionViewFlowLayout.new;
    layout.minimumInteritemSpacing = spacing;   //列距
    layout.minimumLineSpacing = spacing;        //行距
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    UICollectionView *colleview = [[UICollectionView alloc] initWithFrame:self.cardView.contentView.bounds collectionViewLayout:layout];
    colleview.delegate = self;
    colleview.dataSource = self;
    //圆角 背色
    colleview.backgroundColor = self.cardView.contentView.backgroundColor;
    colleview.layer.cornerRadius = 8.0f;
    colleview.layer.masksToBounds = YES;
    //注册不同类型的cell
    switch (type) {
        case ChartsAlbumsType:
            [colleview registerClass:ChartsAlbumCell.class forCellWithReuseIdentifier:cellId];
            break;
        case ChartsPlaylistsType:
            [colleview registerClass:ChartsPlaylistsCell.class forCellWithReuseIdentifier:cellId];
            break;
        case ChartsMusicVideosType:
            [colleview registerClass:ChartsMusicVideoCell.class forCellWithReuseIdentifier:cellId];
            break;
        case ChartsSongsType:
            [colleview registerClass:ChartsSongCell.class forCellWithReuseIdentifier:cellId];
            break;
    }
    return colleview;
}

#pragma mark - getter
-(NewCardView *)cardView{
    if (!_cardView) {
        CGFloat x = 0;
        CGFloat y = CGRectGetMaxY(self.navigationController.navigationBar.frame);
        CGFloat w = CGRectGetWidth(self.view.frame);
        CGFloat h = CGRectGetHeight(self.view.frame)-(y+CGRectGetHeight(self.tabBarController.tabBar.frame));
        _cardView = [[NewCardView alloc] initWithFrame:CGRectMake(x, y, w, h)];
    }
    return _cardView;
}


#pragma mark - setter


@end
