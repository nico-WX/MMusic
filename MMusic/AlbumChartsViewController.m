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

@interface AlbumChartsViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
/**专辑列表*/
@property(nonatomic, strong) NSArray<Album*> *albums;
/**下一页*/
@property(nonatomic, strong) NSString *next;

@property(nonatomic, strong) UICollectionView *collectionView;

/**卡片视图*/
@property(nonatomic, strong) NewCardView *cardView;
@end

@implementation AlbumChartsViewController

static NSString * const reuseIdentifier = @"AlbumChartsCell";

/**cell 间隔*/
CGFloat spacing = 5.0f;
- (void)viewDidLoad {
    [super viewDidLoad];

    [self requestData];
    //将集合视图添加到Card View 上
    self.cardView = [[NewCardView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.cardView];

    self.collectionView = ({
         UICollectionViewFlowLayout *layout = UICollectionViewFlowLayout.new;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;

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
        UIEdgeInsets padding = UIEdgeInsetsMake((statusH+navH+10), 10, (tabH+0), 10);

        //Layout cardView
        UIView *superview = self.view;
        [self.cardView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(superview.mas_top).offset(padding.top);
            make.left.equalTo(superview.mas_left).offset(padding.left);
            make.right.equalTo(superview.mas_right).offset(-padding.right);
            make.bottom.equalTo(superview.mas_bottom).offset(-padding.bottom);
        }];

        //Layout collectionView
        superview = self.cardView.contentView;
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(superview.mas_top);
            make.left.equalTo(superview.mas_left).with.offset(5);
            make.right.equalTo(superview.mas_right).with.offset(-5);
            make.bottom.equalTo(superview.mas_bottom).with.offset(-5);
        }];
    });

    //上拉加载更多
    __weak typeof(self) weakSelf = self;
    self.collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        Log(@"加载下一页");
        if (weakSelf.next) {
            [weakSelf loadNextPage];
        }
    }];

    //下拉刷新
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        Log(@"刷新");
        weakSelf.albums = nil;
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
                [self serializationDict:json];
                [self.collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            }
        }
    }];
}

/**解析返回的JSON 到对象模型中*/
- (void)serializationDict:(NSDictionary*) json{
    json = [json objectForKey:@"results"];
    for (NSDictionary *temp in [json objectForKey:@"albums"] ) {
        NSString *page = [temp objectForKey:@"next"];
        [self.cardView.titleLabel performSelectorOnMainThread:@selector(setText:) withObject:[temp objectForKey:@"name"] waitUntilDone:NO];
        if (page) {
            self.next = page;
        }else{
            self.next = nil;
        }
        NSMutableArray *tempList = [NSMutableArray array];
        for (NSDictionary *albumData in [temp objectForKey:@"data"]) {
            Album *album = [Album instanceWithDict:[albumData objectForKey:@"attributes"]];
            [tempList addObject:album];
        }
        //添加到当前 列表
        if (!_albums) {
            self.albums = tempList;
        }else{
            self.albums = [self.albums arrayByAddingObjectsFromArray:tempList];
        }
    }
}

/**加载下一页数据*/
-(void) loadNextPage{
    Log(@"nextPage!!!");
    if (self.next) {
        NSURLRequest *request = [[RequestFactory requestFactory] createRequestWithHerf:self.next];
        [self dataTaskWithdRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (!error) {
                NSDictionary *json =  [self serializationDataWithResponse:response data:data error:error];
                if (json) {
                    [self serializationDict:json];
                    [self.collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                }
            }
        }];
    }
}

#pragma mark <UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.albums.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ChartsAlbumCell *cell = (ChartsAlbumCell*)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    Album *album = [self.albums objectAtIndex:indexPath.row];

    //title
    [cell.titleLabel setText:album.name];
    cell.contentView.backgroundColor = self.cardView.contentView.backgroundColor;

    //专辑
    Artwork *artwork = album.artwork;
    NSString *path = IMAGEPATH_FOR_URL(artwork.url);
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    if (image) {
        [cell.artworkView setImage:image];
    }else{
        CGFloat w = CGRectGetWidth(cell.bounds);
        CGFloat h = w;//CGRectGetHeight(cell.bounds);
        if (h != 0) {
            NSString *url = [self stringReplacingOfString:artwork.url height:h width:w];
            [cell.artworkView sd_setImageWithURL:[NSURL URLWithString:url] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                BOOL succeed = [[NSFileManager defaultManager] createFileAtPath:path contents:UIImagePNGRepresentation(image) attributes:nil];
                if (!succeed) [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
            }];
        }
    }
    cell.backgroundColor = UIColor.whiteColor;
    return cell;
}

#pragma mark <UICollectionViewDelegate>
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat w = (CGRectGetWidth(collectionView.bounds) - spacing*2)/2;
    CGFloat h = w+28; //28 为标题的高度
    return CGSizeMake(w, h);
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    Album *album = [self.albums objectAtIndex:indexPath.row];
    DetailViewController *detailVC = [[DetailViewController alloc] initWithAlbum:album];
    [self.navigationController pushViewController:detailVC animated:YES];
}

@end
