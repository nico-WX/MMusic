//
//  MusicVideoChartsViewController.m
//  MMusic
//
//  Created by Magician on 2018/4/2.
//  Copyright © 2018年 com.😈. All rights reserved.
//
#import <MJRefresh.h>
#import <Masonry.h>
#import <MediaPlayer/MediaPlayer.h>
#import <UIImageView+WebCache.h>

#import "MusicVideoChartsViewController.h"
#import "ChartsMusicVideoCell.h"
#import "NewCardView.h"

#import "RequestFactory.h"
#import "MusicVideo.h"
#import "Artwork.h"

@interface MusicVideoChartsViewController()<UICollectionViewDataSource,
UICollectionViewDelegate,MPSystemMusicPlayerController,UICollectionViewDelegateFlowLayout>
/**卡片视图*/
@property(nonatomic, strong) NewCardView *cardView;

/**MV 列表*/
@property(nonatomic, strong) NSArray<MusicVideo*> *mvList;

/**下一页*/
@property(nonatomic, strong) NSString *next;

@property(nonatomic, strong) NSArray<MPMusicPlayerPlayParameters*> * parametersList;
@property(nonatomic, strong) MPMusicPlayerPlayParametersQueueDescriptor *queueDesc;
@property(nonatomic, strong) UICollectionView *collectionView;
@end

@implementation MusicVideoChartsViewController

static NSString * const reuseIdentifier = @"MVChartsCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self requestData];

    //将集合视图移到cardView 上
    self.cardView = ({
        NewCardView *view = [[NewCardView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:view];
        view;
    });

    self.collectionView = ({
        UICollectionViewFlowLayout *layout = UICollectionViewFlowLayout.new;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        UICollectionView *view = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        view.layer.cornerRadius = 8.0f;
        view.layer.masksToBounds = YES;
        view.backgroundColor = self.cardView.contentView.backgroundColor;
        view.dataSource = self;
        view.delegate = self;
        [view registerClass:[ChartsMusicVideoCell class] forCellWithReuseIdentifier:reuseIdentifier];
        view;
    });

    //添加视图
    [self.cardView.contentView addSubview:self.collectionView];

    //布局
    ({
        //导航栏状态栏 tabBar 高度
        CGFloat statusH = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
        CGFloat navH = CGRectGetHeight(self.navigationController.navigationBar.frame);
        CGFloat tabH = 0.0f;//CGRectGetHeight(self.tabBarController.tabBar.frame);

        UIEdgeInsets padding = UIEdgeInsetsMake((statusH+navH+4), 4, (tabH+0), 4);
        //layout cardView
        UIView *superview = self.view;
        [self.cardView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(superview.mas_top).with.offset(padding.top);
            make.left.mas_equalTo(superview.mas_left).with.offset(padding.left);
            make.right.mas_equalTo(superview.mas_right).with.offset(-padding.right);
            make.bottom.mas_equalTo(superview.mas_bottom).with.offset(-padding.bottom);
        }];

        //Layout collectionView
        superview = self.cardView.contentView;
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            UIEdgeInsets padding = UIEdgeInsetsMake(0, 5, 5, 5);
            make.edges.mas_equalTo(superview).with.insets(padding);
        }];
    });

    __weak typeof(self) weakSelf = self;
    //刷新
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        weakSelf.mvList = nil;
        [weakSelf requestData];
        [weakSelf.collectionView.mj_header endRefreshing];
    }];

    //上拉加载更多
    self.collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        if (weakSelf.next) {
            [weakSelf loadNextPage];
        }else{
            [weakSelf.collectionView.mj_footer endRefreshingWithNoMoreData];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**请求数据*/
-(void)requestData{
    NSURLRequest *urlRequest = [[RequestFactory requestFactory] createChartWithChartType:ChartMusicVideosType];
    [self dataTaskWithdRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSDictionary *json = [self serializationDataWithResponse:response data:data error:error];
            if (json) {
                [self serializationDict:json];
            }else{
                [self requestHongKongMVData];
            }
        }
    }];
}

/**加载下一页数据*/
-(void) loadNextPage{
    if (self.next) {
        NSURLRequest *request = [[RequestFactory requestFactory] createRequestWithHerf:self.next];
        [self dataTaskWithdRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (!error) {
                NSDictionary *json =  [self serializationDataWithResponse:response data:data error:error];
                if (json) {
                    [self serializationDict:json];
                }
            }
        }];
    }
}

/**内地无MV 排行数据, 请求香港地区*/
- (void) requestHongKongMVData{
    NSString *path = @"https://api.music.apple.com/v1/catalog/hk/charts?types=music-videos";
    NSURLRequest *request = [self createRequestWithURLString:path setupUserToken:NO];
    [self dataTaskWithdRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSDictionary *json = [self serializationDataWithResponse:response data:data error:error];
            if (json) {
                [self serializationDict:json];
            }
        }
    }];
}

/**解析返回的JSON 到对象模型中*/
- (void)serializationDict:(NSDictionary*) json{
    json = [json objectForKey:@"results"];
    for (NSDictionary *temp in [json objectForKey:@"music-videos"] ) {

        NSMutableArray *tempList = [NSMutableArray array];
        for (NSDictionary *mvData in [temp objectForKey:@"data"]) {
            //过滤掉 无值的情况
            if ([mvData objectForKey:@"attributes"]) {
                MusicVideo *mv = [MusicVideo instanceWithDict:[mvData objectForKey:@"attributes"]];
                [tempList addObject:mv];
            }
        }
        NSString *page = [temp objectForKey:@"next"];
        self.next = page ? page : nil;
        self.mvList = self.mvList==NULL ? tempList : [self.mvList arrayByAddingObjectsFromArray:tempList];

        //刷新UI
        dispatch_async(dispatch_get_main_queue(), ^{
            self.cardView.titleLabel.text = [temp objectForKey:@"name"];
            [self.collectionView reloadData];
            [self.collectionView.mj_footer endRefreshing];
        });

        NSMutableArray *queueList = [NSMutableArray array];
        for (MusicVideo *mv in self.mvList) {
            NSDictionary *dict = mv.playParams;
            MPMusicPlayerPlayParameters *parm = [[MPMusicPlayerPlayParameters alloc] initWithDictionary:dict];
            [queueList addObject:parm];
        }
        self.parametersList = queueList;
        self.queueDesc = [[MPMusicPlayerPlayParametersQueueDescriptor alloc]  initWithPlayParametersQueue:queueList];
    }
}
#pragma mark <UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.mvList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ChartsMusicVideoCell *cell = (ChartsMusicVideoCell*)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];

    // Configure the cell
    MusicVideo *mv = [self.mvList objectAtIndex:indexPath.row];
    cell.titleLabel.text = mv.name;
    cell.artistLabel.text = mv.artistName;

    Artwork *art = mv.artwork;
    [self showImageToView:cell.artworkView withImageURL:art.url cacheToMemory:YES];

    cell.backgroundColor = UIColor.whiteColor;
    return cell;
}

#pragma mark <UICollectionViewDelegate>

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self.queueDesc setStartItemPlayParameters:[self.parametersList objectAtIndex:indexPath.row]];
    [self openToPlayQueueDescriptor:self.queueDesc];
}
/**跳转到应用播放*/
- (void)openToPlayQueueDescriptor:(MPMusicPlayerQueueDescriptor *)queueDescriptor{
    UIApplication *app = [UIApplication sharedApplication];
   // NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString]; //自己的应用设置
    NSURL *url = [NSURL URLWithString:@"Music:prefs:root=MUSIC"];

    if ([app canOpenURL:url]) {
        [app openURL:url options:@{} completionHandler:^(BOOL success) {
            [[MPMusicPlayerController systemMusicPlayer] setQueueWithDescriptor:queueDescriptor];
            [[MPMusicPlayerController systemMusicPlayer] play];
        }];
    }
}

#pragma mark <UICollectionViewDelegateFlowLayout>
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat w = CGRectGetWidth(collectionView.bounds);
    CGFloat h = w*0.75;
    return CGSizeMake(w, h);
}

@end
