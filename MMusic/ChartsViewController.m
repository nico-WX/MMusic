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
#import "ChartsCell.h"
#import "AlbumCell.h"
#import "PlaylistsCell.h"
#import "MusicVideoCell.h"
#import "ChartsSongCell.h"
#import "ChartsSectionView.h"

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

//集合视图
@property(nonatomic, strong) UICollectionView *collectionView;
//播放视图控制
@property(nonatomic, strong) PlayerViewController *playerVC;
//songs  歌曲排行榜 音乐列表
@property(nonatomic, strong) NSArray<Song*> *songs;

//data
@property(nonatomic, strong) NSArray<Chart*> *results;

//播放参数数组
@property(nonatomic, strong) NSArray<NSDictionary*> *playParametersList;

@end

static CGFloat const spacing = 2.0f;

static NSString *const cellId = @"cellReuseIdentifier";
static NSString *const sectionId = @"colletionSectionReuseIdentifier";
@implementation ChartsViewController

#pragma mark - init
-(instancetype)initWithChartsType:(ChartsType)type{
    if (self = [super init]) {
        _request = [[RequestFactory new] fetchChartsFromType:type];
        _type = type;
    }
    return self;
}

#pragma mark - cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;

    [self.view addSubview:self.collectionView];

    Log(@"url =%@",self.request.URL.absoluteString);
    [self requestDataFromRequest:self.request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    //布局 集合视图
    UIView *superview = self.view;
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat y = CGRectGetMaxY(self.navigationController.navigationBar.frame);
        CGFloat tabH = 0.0f;
        UIEdgeInsets padding = UIEdgeInsetsMake(y+spacing, spacing, tabH, spacing);

        make.edges.mas_equalTo(superview).with.insets(padding);
    }];
}

#pragma mark - UICollectionView DataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return self.results.count;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    Chart *chart = [self.results objectAtIndex:section];
    return chart.data.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    ChartsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];

    Chart *chart = [self.results objectAtIndex:indexPath.section];
    Resource *resource = [chart.data objectAtIndex:indexPath.row];

    cell.titleLabel.text = [resource.attributes valueForKey:@"name"];
    //self.title = chart.name;

    Artwork *art = [Artwork instanceWithDict:[resource.attributes valueForKey:@"artwork"]];
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

    cell.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];

    //选中背景色
    UIView *selectedView = [[UIView alloc] initWithFrame:cell.bounds];
    selectedView.backgroundColor = [UIColor colorWithRed:0.80 green:0.80 blue:0.80 alpha:0.80];
    cell.selectedBackgroundView = selectedView;

    return cell;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        ChartsSectionView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:sectionId forIndexPath:indexPath];
        Chart *chart = [self.results objectAtIndex:indexPath.section];
        view.titleLabel.text = chart.name;
        return view;
    }else{
        return nil;
    }
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
            //MV 排行榜 选中跳转应用播放
        case ChartsMusicVideosType:{
            MPMusicPlayerPlayParametersQueueDescriptor *queue;
            queue = [self playParametersQueueFromParams:self.playParametersList startAtIndexPath:indexPath];
            [self openToPlayQueueDescriptor:queue];
            //[self openToPlayQueueDescriptor:[self openToPlayMusicVideosAtIndexPath:indexPath]];
        }
            break;

            //歌曲排行榜, 选中直接播放
        case ChartsSongsType:{
            //[self playSongQueue:[self openToPlayMusicVideosAtIndexPath:indexPath] atIndexPath:indexPath];
            Song *start = [self.songs objectAtIndex:indexPath.row];
            //选中的歌曲正在播放中, 直接弹出视图
            if (![start isEqualToMediaItem:self.playerVC.playerController.nowPlayingItem]) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    MPMusicPlayerPlayParametersQueueDescriptor *queue;
                    queue = [self playParametersQueueFromParams:self.playParametersList startAtIndexPath:indexPath];
                    [self.playerVC.playerController setQueueWithDescriptor:queue];
                    [self.playerVC.playerController prepareToPlay];
                });
            }
            [self.playerVC showFromViewController:self withSongs:self.songs startItem:start];

        }
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

    //不同的cell 返回不同的 size
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
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    CGFloat h = 44.0f;
    CGFloat w = CGRectGetWidth(collectionView.bounds);
    return CGSizeMake(w, h);
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
        NSURLRequest *request = [[RequestFactory new] createRequestWithHref:nextHref];
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


        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = UIColor.whiteColor;

        //注册节头
        [_collectionView registerClass:ChartsSectionView.class
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:sectionId];

        //注册cell
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

        //上拉加载更多
        __weak typeof(self) weakSelf = self;
        _collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            Chart *chart = [self.results firstObject];
            if (chart.next) {
                [weakSelf loadNextPage:chart.next];
            }else{
                [weakSelf.collectionView.mj_footer endRefreshingWithNoMoreData];
            }
        }];

        //下拉刷新
        _collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            self.results = nil;
            [weakSelf requestDataFromRequest:weakSelf.request];
        }];

    }
    return _collectionView;
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

-(NSArray<NSDictionary *> *)playParametersList{
    if (!_playParametersList) {
        NSMutableArray<NSDictionary*> *temp = [NSMutableArray array];
        [self.results enumerateObjectsUsingBlock:^(Chart * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj.data enumerateObjectsUsingBlock:^(Resource * _Nonnull res, NSUInteger idx, BOOL * _Nonnull stop) {
                [temp addObject:[res.attributes valueForKey:@"playParams"]];
            }];
        }];
        _playParametersList = temp;
    }
    return _playParametersList;
}


@end
