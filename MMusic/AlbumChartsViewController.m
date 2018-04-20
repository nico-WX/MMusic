//
//  AlbumChartsViewController.m
//  MMusic
//
//  Created by Magician on 2018/4/2.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <Masonry.h>
#import <UIImageView+WebCache.h>
#import <MJRefresh.h>

#import "AlbumChartsViewController.h"
#import "ChartsAlbumCell.h"
#import "NewCardView.h"
#import "DetailViewController.h"

#import "RequestFactory.h"
#import "Album.h"
#import "Artwork.h"
#import "Resource.h"
#import "ResponseRoot.h"

@interface AlbumChartsViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
/**资源列表*/
@property(nonatomic, strong) NSArray<Resource*> *resources;
/**下一页*/
@property(nonatomic, strong) NSString *next;

@property(nonatomic, strong) UICollectionView *collectionView;
/**卡片视图*/
@property(nonatomic, strong) NewCardView *cardView;
@end

@implementation AlbumChartsViewController

static NSString * const reuseIdentifier = @"AlbumChartsCell";
/**cell 间隔*/
static CGFloat const spacing = 2.0f;
- (void)viewDidLoad {
    [super viewDidLoad];

    [self requestData];
    //将集合视图添加到Card View 上
    self.cardView = [[NewCardView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.cardView];

    self.collectionView = ({
         UICollectionViewFlowLayout *layout = UICollectionViewFlowLayout.new;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.minimumInteritemSpacing = spacing;
        layout.minimumLineSpacing = spacing;

        UICollectionView *view = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        [view registerClass:[ChartsAlbumCell class] forCellWithReuseIdentifier:reuseIdentifier];
        view.delegate = self;
        view.dataSource = self;
        //圆角 背色
        view.backgroundColor = self.cardView.contentView.backgroundColor;
        view.layer.cornerRadius = 8.0f;
        view.layer.masksToBounds = YES;
        view;
    });
    [self.cardView.contentView addSubview:self.collectionView];

    //layout
    ({
        //导航栏状态栏 tabBar 高度
        CGFloat statusH = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
        CGFloat navH = CGRectGetHeight(self.navigationController.navigationBar.frame);
        //添加了UIPageController,   不用计数Tabbar高度
        CGFloat tabH = 0.0f;//CGRectGetHeight(self.tabBarController.tabBar.frame);

        //边距
        UIEdgeInsets padding = UIEdgeInsetsMake((statusH+navH+4), 4, (tabH+0), 4);

        //Layout cardView
        UIView *superview = self.view;
        [self.cardView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(superview.mas_top).offset(padding.top);
            make.left.mas_equalTo(superview.mas_left).offset(padding.left);
            make.right.mas_equalTo(superview.mas_right).offset(-padding.right);
            make.bottom.mas_equalTo(superview.mas_bottom).offset(-padding.bottom);
        }];

        //Layout collectionView
        superview = self.cardView.contentView;
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(superview.mas_top);
            make.left.mas_equalTo(superview.mas_left).with.offset(spacing*2);
            make.right.mas_equalTo(superview.mas_right).with.offset(-spacing*2);
            make.bottom.mas_equalTo(superview.mas_bottom).with.offset(-spacing*2);
        }];
    });

    //上拉加载更多
    __weak typeof(self) weakSelf = self;
    self.collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        if (weakSelf.next) {
            [weakSelf loadNextPage];
        }else{
            [weakSelf.collectionView.mj_footer endRefreshingWithNoMoreData];
        }
    }];

    //下拉刷新
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        self.resources = nil;
        [weakSelf requestData];
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/**请求数据*/
-(void)requestData{
    NSURLRequest *urlRequest = [[RequestFactory requestFactory] createChartWithChartType:ChartAlbumsType];
    [self dataTaskWithdRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSDictionary *json = [self serializationDataWithResponse:response data:data error:error];
            if (json) {
                NSArray *list = [self serializationDict:json];
                self.resources = self.resources==NULL ? list : [self.resources arrayByAddingObjectsFromArray:list];
                //刷新
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.collectionView reloadData];
                    [self.collectionView.mj_header endRefreshing];
                });
            }
        }
    }];
}

/**解析返回的JSON 到对象模型中*/
- (NSArray<Resource*>*)serializationDict:(NSDictionary*) json{
    json = [json objectForKey:@"results"];

    NSMutableArray<Resource*> *resouceList = NSMutableArray.new;
    for (NSDictionary *subJSON in [json objectForKey:@"albums"] ) {
        //解析json 到数组
        for (NSDictionary *albumDict in [subJSON objectForKey:@"data"]) {
            Resource *resource = [Resource instanceWithDict:albumDict];
            [resouceList addObject:resource];
        }

        //记录分页地址
        NSString *page = [subJSON objectForKey:@"next"];
        self.next = page ? page : nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            //设置title
            self.cardView.titleLabel.text = [subJSON objectForKey:@"name"];
        });
    }
    return resouceList;
}

/**加载下一页数据*/
-(void) loadNextPage{
    if (self.next) {
        NSURLRequest *request = [[RequestFactory requestFactory] createRequestWithHerf:self.next];
        [self dataTaskWithdRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSDictionary *json =  [self serializationDataWithResponse:response data:data error:error];
            if (json) {
                NSArray *list = [self serializationDict:json];
                self.resources = [self.resources arrayByAddingObjectsFromArray:list];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.collectionView reloadData];
                    [self.collectionView.mj_footer endRefreshing];
                });
            }
        }];
    }
}

#pragma mark <UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.resources.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ChartsAlbumCell *cell = (ChartsAlbumCell*)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    Resource *resouce = [self.resources objectAtIndex:indexPath.row];

    if ([resouce.type isEqualToString:@"albums"]) {
        Album *album = [Album instanceWithDict:resouce.attributes];
        cell.titleLabel.text = album.name;
        [self showImageToView:cell.artworkView withImageURL:album.artwork.url cacheToMemory:YES];
    }
    cell.contentView.backgroundColor = self.cardView.contentView.backgroundColor;
    cell.backgroundColor = UIColor.whiteColor;
    return cell;
}

#pragma mark <UICollectionViewDelegate>
//cell size
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat w = (CGRectGetWidth(collectionView.bounds) - spacing*2)/2;
    CGFloat h = w+28; //28 为cell标题的高度
    return CGSizeMake(w, h);
}
// selected cell
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    DetailViewController *detailVC = [[DetailViewController alloc] initWithResource:[self.resources objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:detailVC animated:YES];
}

@end
