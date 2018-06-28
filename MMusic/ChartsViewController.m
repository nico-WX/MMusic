//
//  ChartsViewController.m
//  MMusic
//
//  Copyright © 2018年 com.😈. All rights reserved.
//  pod and system
#import <Masonry.h>
#import <MJRefresh.h>
#import <MediaPlayer/MediaPlayer.h>


//Controller
#import "ChartsViewController.h"
#import "DetailViewController.h"
#import "PlayerViewController.h"

//view  and cell
#import "ResourceCollectionViewCell.h"
#import "MusicVideosCollectionCell.h"
#import "SongCell.h"
#import "ChartsSectionView.h"

//model and tool

#import "MusicKit.h"
#import "ResponseRoot.h"
#import "Chart.h"
#import "Resource.h"
#import "Album.h"
#import "Playlist.h"
#import "MusicVideo.h"
#import "Song.h"
#import "Artwork.h"

@interface ChartsViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,MPSystemMusicPlayerController,UITableViewDelegate,UITableViewDataSource>


//集合视图(展示albums, playlists, musicvideos 排行榜)
@property(nonatomic, strong) UICollectionView *collectionView;
//表视图(展示songs 排行榜)
@property(nonatomic, strong) UITableView *tableView;

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

static NSString *const songId = @"songReuseIdentifier";
static NSString *const cellId = @"cellReuseIdentifier";
static NSString *const sectionId = @"colletionSectionReuseIdentifier";
@implementation ChartsViewController

#pragma mark - init
-(instancetype)initWithResponseRoot:(ResponseRoot *)root{
    if (self = [super init]) {
        _root = roo;
    }
    return self;
}

#pragma mark - cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;

    //添加不同的 subview

    Resource *resource = self.root.data.firstObject;
    if ([resource.type isEqualToString:@"songs"]) {
        [self.view addSubview:self.tableView];
    }else{
        [self.view addSubview:self.collectionView];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    //布局
    UIView *superview = self.view;
    CGFloat y = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    CGFloat tabH = 0.0f;
    UIEdgeInsets padding = UIEdgeInsetsMake(y+spacing, spacing, tabH, spacing);
    if (self.type == ChartsSongs) {
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(superview).insets(padding);
        }];
    }else{
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(superview).with.insets(padding);
        }];
    }
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
    ResourceCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];

    Chart *chart = [self.results objectAtIndex:indexPath.section];
    Resource *resource = [chart.data objectAtIndex:indexPath.row];

    cell.nameLabel.text = [resource.attributes valueForKey:@"name"];

    Artwork *artwork = [Artwork instanceWithDict:[resource.attributes valueForKey:@"artwork"]];
    [self showImageToView:cell.artworkView withImageURL:artwork.url cacheToMemory:YES];

    if (self.type == ChartsMusicVideos) {
        cell.artistLabel.text = [resource.attributes valueForKey:@"artistName"];
    }

//    //选中背景色
//    UIView *selectedView = [[UIView alloc] initWithFrame:cell.bounds];
//    selectedView.backgroundColor = [UIColor colorWithRed:0.80 green:0.80 blue:0.80 alpha:0.80];
//    cell.selectedBackgroundView = selectedView;

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
        case ChartsAlbums:
            [self showAlbumsOrPlaylistsChartsDetailFromIndexPath:indexPath];
            break;
        case ChartsPlaylists:
            [self showAlbumsOrPlaylistsChartsDetailFromIndexPath:indexPath];
            break;
            //MV 排行榜 选中跳转应用播放
        case ChartsMusicVideos:{
            MPMusicPlayerPlayParametersQueueDescriptor *queue;
            queue = [self playParametersQueueFromParams:self.playParametersList startAtIndexPath:indexPath];
            [self openToPlayQueueDescriptor:queue];
            //[self openToPlayQueueDescriptor:[self openToPlayMusicVideosAtIndexPath:indexPath]];
        }
            break;
        case ChartsSongs:
    
            break;


//            //歌曲排行榜, 选中直接播放
//        case ChartsSongsType:{
//            //[self playSongQueue:[self openToPlayMusicVideosAtIndexPath:indexPath] atIndexPath:indexPath];
//            Song *start = [self.songs objectAtIndex:indexPath.row];
//            //选中的歌曲正在播放中, 直接弹出视图
//            if (![start isEqualToMediaItem:self.playerVC.playerController.nowPlayingItem]) {
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                    MPMusicPlayerPlayParametersQueueDescriptor *queue;
//                    queue = [self playParametersQueueFromParams:self.playParametersList startAtIndexPath:indexPath];
//                    [self.playerVC.playerController setQueueWithDescriptor:queue];
//                    [self.playerVC.playerController prepareToPlay];
//                });
//            }
//            [self.playerVC showFromViewController:self withSongs:self.songs startItem:start];
//
//        }
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
        case ChartsAlbums:
        case ChartsPlaylists:
             w = (CGRectGetWidth(collectionView.bounds) - spacing*2)/2;
             h = w+28; //28 为cell标题的高度
            return CGSizeMake(w, h);
            break;

        case ChartsMusicVideos:
            w = CGRectGetWidth(collectionView.bounds);
            h = w*0.75;
            return CGSizeMake(w, h);
            break;

        default:
            return CGSizeZero;
        break;
    }
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    CGFloat h = 44.0f;
    CGFloat w = CGRectGetWidth(collectionView.bounds);
    return CGSizeMake(w, h);
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.results.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.results objectAtIndex:section].data.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SongCell *cell = [tableView dequeueReusableCellWithIdentifier:songId];
    cell.song = [self.songs objectAtIndex:indexPath.row];
    cell.numberLabel.text = [NSString stringWithFormat:@"%.2ld",indexPath.row+1];
    return cell;
}


#pragma mark - 数据请求 和解析
-(void)requestDataFromRequest:(NSURLRequest*) request{

    [self dataTaskWithRequest:request handler:^(NSDictionary *json, NSHTTPURLResponse *response) {
        if (json) {
            self.results = [self serializationJSON:json];
            //刷新
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.type == ChartsSongs) {
                    [self.tableView reloadData];
                }else{
                    [self.collectionView reloadData];
                    [self.collectionView.mj_header endRefreshing];
                }
            });
        }else{
            //MV 无排行内容  用香港的
            [self requestHongKongMVData];
        }
    }];
}

/**内地无MV 排行数据, 请求香港地区*/
- (void) requestHongKongMVData{
    NSString *path = @"https://api.music.apple.com/v1/catalog/hk/charts?types=music-videos";
    NSURLRequest *request = [self createRequestWithURLString:path setupUserToken:NO];
    [self dataTaskWithRequest:request handler:^(NSDictionary *json, NSHTTPURLResponse *response) {
        if (json) {
            self.results = [self serializationJSON:json];
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
        NSURLRequest *request = [self createRequestWithHref:nextHref];
        [self dataTaskWithRequest:request handler:^(NSDictionary *json, NSHTTPURLResponse *response) {
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
-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView setRowHeight:44.0f];

        [_tableView registerClass:SongCell.class forCellReuseIdentifier:songId];
    }
    return _tableView;
}
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
            case ChartsAlbums:
            case ChartsPlaylists:
                [_collectionView registerClass:ResourceCollectionViewCell.class forCellWithReuseIdentifier:cellId];
                break;

            case ChartsMusicVideos:
                [_collectionView registerClass:MusicVideosCollectionCell.class forCellWithReuseIdentifier:cellId];
                break;

                default:
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
            [MusicKit.new.api chartsByType:self.type callBack:^(NSDictionary *json, NSHTTPURLResponse *response) {
                if (json) {
                    self.results = [self serializationJSON:json];
                    //刷新
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (self.type == ChartsSongs) {
                            [self.tableView reloadData];
                        }else{
                            [self.collectionView reloadData];
                            [self.collectionView.mj_header endRefreshing];
                        }
                    });
                }else{
                    //MV 无排行内容  用香港的
                    [self requestHongKongMVData];
                }
            }];
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
                //部分 返回的json 无该数据
                if ([res.attributes valueForKey:@"playParams"]) {
                    [temp addObject:[res.attributes valueForKey:@"playParams"]];
                }
            }];
        }];
        _playParametersList = temp;
    }
    return _playParametersList;
}


@end
