//
//  ChartsViewController.m
//  MMusic
//
//  Copyright © 2018年 com.😈. All rights reserved.
//  pod and system
#import <Masonry.h>
#import <MJRefresh.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MediaToolbox/MediaToolbox.h>

//Controller
#import "ChartsViewController.h"
#import "DetailViewController.h"
#import "PlayerViewController.h"

//view  and cell
#import "NewCardView.h"
#import "ChartsCell.h"
#import "AlbumCell.h"
#import "PlaylistsCell.h"
#import "MusicVideoCell.h"
#import "ChartsSongCell.h"

//model and tool
#import "Chart.h"
#import "Resource.h"
#import "Album.h"
#import "Playlist.h"
#import "MusicVideo.h"
#import "Song.h"
#import "Artwork.h"

@interface ChartsViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,MPSystemMusicPlayerController>
@property(nonatomic, assign) ChartsType type;
@property(nonatomic, strong) NSURLRequest *request;
//容器 viwe
@property(nonatomic, strong) NewCardView *cardView;
//集合视图
@property(nonatomic, strong) UICollectionView *collectionView;
//播放视图控制
@property(nonatomic, strong) PlayerViewController *playerVC;
//songs  歌曲排行榜 音乐列表
@property(nonatomic, strong) NSArray<Song*> *songs;

//data
@property(nonatomic) NSArray<Chart*> *results;
@end

static CGFloat const spacing = 2.0f;
static NSString *const cellId = @"cellReuseIdentifier";
@implementation ChartsViewController

#pragma mark - init
-(instancetype)initWithChartsType:(ChartsType)type{
    if (self = [super init]) {
        _request = [[RequestFactory new] createChartWithChartType:type];
        _type = type;
    }
    return self;
}

#pragma mark - cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;

    [self.view addSubview:self.cardView];
    [self.cardView.contentView addSubview:self.collectionView];
    
    [self requestDataFromRequest:self.request];

    __weak typeof(self) weakSelf = self;
    //上拉加载更多
    self.collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        Chart *chart = [self.results firstObject];
        if (chart.next) {
            [weakSelf loadNextPage:chart.next];
        }else{
            [weakSelf.collectionView.mj_footer endRefreshingWithNoMoreData];
        }
    }];

    //下拉刷新
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        self.results = nil;
        [weakSelf requestDataFromRequest:weakSelf.request];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    CGFloat y = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    CGFloat tabH = 0.0f; // CGRectGetHeight(self.tabBarController.tabBar.frame);
    UIEdgeInsets padding = UIEdgeInsetsMake(y+4, 4, tabH+4, 4);
    UIView *superview = self.view;
    [self.cardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(superview).with.insets(padding);
    }];

    superview = self.cardView.contentView;
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        UIEdgeInsets insets = UIEdgeInsetsMake(0, 4, 4, 4);
        make.edges.mas_equalTo(superview).with.insets(insets);
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

    ChartsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    Chart *chart = [self.results objectAtIndex:indexPath.section];
    Resource *resource = [chart.data objectAtIndex:indexPath.row];

    cell.titleLabel.text = [resource.attributes valueForKey:@"name"];
    self.title = chart.name;

    NSDictionary *artDict = [resource.attributes valueForKey:@"artwork"];
    Artwork *art = [Artwork instanceWithDict:artDict];
    [self showImageToView:cell.artworkView withImageURL:art.url cacheToMemory:YES];
    if ([cell respondsToSelector:@selector(artistLabel)]) {
        NSString *artist;
        if ([resource.attributes valueForKey:@"artistName"]) {
            artist = [resource.attributes valueForKey:@"artistName"];
        }else if ([resource.attributes valueForKey:@"curatorName"]){
            artist = [resource.attributes valueForKey:@"curatorName"];
        }
        cell.artistLabel.text = artist;
    }

    //选中背景色
    UIView *selectedView = [[UIView alloc] initWithFrame:cell.bounds];
    selectedView.backgroundColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:0.88];
    cell.selectedBackgroundView = selectedView;
    return cell;
}
#pragma mark - UICollectionView Delegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    switch (self.type) {
        case ChartsAlbumsType:
            [self showAlbumsOrPlaylistsChartsDetailFromIndexPath:indexPath];
            break;
        case ChartsPlaylistsType:
            [self showAlbumsOrPlaylistsChartsDetailFromIndexPath:indexPath];
            break;
        case ChartsMusicVideosType:
            [self openToPlayQueueDescriptor:[self openToPlayMusicVideosAtIndexPath:indexPath]];
            break;
        case ChartsSongsType:
            [self playSongQueue:[self openToPlayMusicVideosAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
    }
}

# pragma mark - 选中cell 辅助操作方法
/**显示专辑/歌单详细*/
-(void)showAlbumsOrPlaylistsChartsDetailFromIndexPath:(NSIndexPath*) indexPath{
    Resource *resource = [[self.results objectAtIndex:indexPath.section].data objectAtIndex:indexPath.row];
    DetailViewController *detailVC = [[DetailViewController alloc] initWithResource:resource];
    [self.navigationController pushViewController:detailVC animated:YES];
}

/**遍历出播放参数 初始化queue*/
- (MPMusicPlayerQueueDescriptor*)openToPlayMusicVideosAtIndexPath:(NSIndexPath*) indexPath{
    NSMutableArray *playParamsList = NSMutableArray.new;
    for (NSDictionary *dict in [self.results firstObject].data) {
        //部分无内容, 过滤
        if ([dict valueForKey:@"attributes"]) {
            [playParamsList addObject:[dict valueForKeyPath:@"attributes.playParams"]];
        }
    }
    return [self playParametersQueueDescriptorFromParams:playParamsList startAtIndexPath:indexPath];
}
/**播放歌曲*/
-(void)playSongQueue:(MPMusicPlayerQueueDescriptor*) queue atIndexPath:(NSIndexPath*) indexPath{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.playerVC.playerController setQueueWithDescriptor:queue];
        [self.playerVC.playerController prepareToPlay];
    });
    Song *startSong = [self.songs objectAtIndex:indexPath.row];
    [self.playerVC showFromViewController:self withSongs:self.songs startItem:startSong];
}

#pragma mark - MPSystemMusicPlayerController
/**跳转到Music APP 播放MV*/
- (void)openToPlayQueueDescriptor:(MPMusicPlayerQueueDescriptor *)queueDescriptor{
    UIApplication *app = [UIApplication sharedApplication];
    NSURL *url = [NSURL URLWithString:@"Music:prefs:root=MUSIC"];
    if ([app canOpenURL:url]) {
        [app openURL:url options:@{} completionHandler:^(BOOL success) {
            [[MPMusicPlayerController systemMusicPlayer] setQueueWithDescriptor:queueDescriptor];
            [[MPMusicPlayerController systemMusicPlayer] play];
        }];
    }
}

#pragma mark - UICollectionView Delegate FlowLayout

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat w;
    CGFloat h;
    switch (self.type) {
        case ChartsAlbumsType:
             w = (CGRectGetWidth(collectionView.bounds) - spacing*2)/2;
             h = w+28; //28 为cell标题的高度
            return CGSizeMake(w, h);
            break;
        case ChartsPlaylistsType:
             w = (CGRectGetWidth(collectionView.bounds) - spacing*2)/2;
             h = w+28; //28 为cell标题的高度
            return CGSizeMake(w, h);
            break;
        case ChartsMusicVideosType:
            w = CGRectGetWidth(collectionView.bounds);
            h = w*0.75;
            return CGSizeMake(w, h);
            break;
        case ChartsSongsType:
            h = 44.0f;
            w = CGRectGetWidth(collectionView.bounds);
            return CGSizeMake(w, h);
            break;
    }
}

#pragma mark - 数据请求 和解析
-(void)requestDataFromRequest:(NSURLRequest*) request{
    [self dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error && data) {
            NSDictionary *json = [self serializationDataWithResponse:response data:data error:error];
            if (json) {
                self.results = [self serializationJSON:json];
                //刷新
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.collectionView reloadData];
                    [self.collectionView.mj_header endRefreshing];
                });
            }else{
                //MV 无排行内容  用香港的
                [self requestHongKongMVData];
            }
        }
    }];
}

/**内地无MV 排行数据, 请求香港地区*/
- (void) requestHongKongMVData{
    NSString *path = @"https://api.music.apple.com/v1/catalog/hk/charts?types=music-videos";
    NSURLRequest *request = [self createRequestWithURLString:path setupUserToken:NO];
    [self dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error && data) {
            NSDictionary *json = [self serializationDataWithResponse:response data:data error:error];
            if (json) {
                self.results = [self serializationJSON:json];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.collectionView reloadData];
                    [self.collectionView.mj_header endRefreshing];
                });
            }
        }
    }];
}

/**加载下一页数据*/
-(void) loadNextPage:(NSString*) nextHref{
    if (nextHref != NULL) {
        NSURLRequest *request = [[RequestFactory new] createRequestWithHerf:nextHref];
        [self dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
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

/**解析JSON*/
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

#pragma mark - getter
-(UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = UICollectionViewFlowLayout.new;
        layout.minimumInteritemSpacing = spacing;   //列距
        layout.minimumLineSpacing = spacing*2;        //行距
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;

        //实例 代理 数据源
        _collectionView = [[UICollectionView alloc] initWithFrame:self.cardView.contentView.bounds collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;

        //圆角 背色
        _collectionView.backgroundColor = self.cardView.contentView.backgroundColor;
        _collectionView.layer.cornerRadius = 8.0f;
        _collectionView.layer.masksToBounds = YES;
        //注册不同类型的cell
        switch (self.type) {
            case ChartsAlbumsType:
                [_collectionView registerClass:AlbumCell.class forCellWithReuseIdentifier:cellId];
                break;
            case ChartsPlaylistsType:
                [_collectionView registerClass:PlaylistsCell.class forCellWithReuseIdentifier:cellId];
                break;
            case ChartsMusicVideosType:
                [_collectionView registerClass:MusicVideoCell.class forCellWithReuseIdentifier:cellId];
                break;
            case ChartsSongsType:
                [_collectionView registerClass:ChartsSongCell.class forCellWithReuseIdentifier:cellId];
                break;
        }
    }
    return _collectionView;
}
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
-(PlayerViewController *)playerVC{
    if (!_playerVC) {
        _playerVC = [PlayerViewController sharePlayerViewController];
        _playerVC.nowPlayingItem = ^(MPMediaItem *item) {

        };
    }
    return _playerVC;
}
-(NSArray<Song *> *)songs{
    if (!_songs) {
        NSMutableArray<Song*> *temp = NSMutableArray.new;
        for (Chart *chart in _results) {
            for (Resource *resource in chart.data) {
                Song *song = [Song instanceWithDict:resource.attributes];
                [temp addObject:song];
            }
        }
        _songs = temp;
    }
    return _songs;
}

#pragma mark - setter


@end
