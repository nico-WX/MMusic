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
//#import "ResourceCollectionViewCell.h"
//#import "MusicVideosCollectionCell.h"
#import "ResourceCell.h"
#import "SongCell.h"

//model and tool
#import "MusicKit.h"
#import "ResponseRoot.h"
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
//@property(nonatomic, strong) NSArray<Chart*> *results;

//播放参数数组
@property(nonatomic, strong) NSArray<NSDictionary*> *playParametersList;

@end

static CGFloat const spacing = 2.0f;

static NSString *const songId = @"songReuseIdentifier";
static NSString *const cellId = @"cellReuseIdentifier";
static NSString *const sectionId = @"colletionSectionReuseIdentifier";
@implementation ChartsViewController

#pragma mark - init
-(instancetype)initWithChart:(Chart *)chart{
    if (self =[super init]) {
        _chart = chart;
        self.title = chart.name;
    }
    return self;
}

#pragma mark - cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;

    //添加不同的 subview
    Resource *resource = self.chart.data.firstObject;
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

    Resource *resource = self.chart.data.firstObject;
    if ([resource.type isEqualToString:@"songs"]) {
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

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.chart.data.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ResourceCell *cell = (ResourceCell*)[collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];

    Resource *resource = [self.chart.data objectAtIndex:indexPath.row];
    if ([resource.type isEqualToString:@"albums"]) {
        cell.album = [Album instanceWithResource:resource];
    }
    if ([resource.type isEqualToString:@"playlists"]) {
        cell.playlists = [Playlist instanceWithResource:resource];
    }
    return cell;
}

#pragma mark - UICollectionView Delegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    Resource *resource = [self.chart.data objectAtIndex:indexPath.row];

    if ([resource.type isEqualToString:@"music-videos"]) {
        MPMusicPlayerPlayParametersQueueDescriptor *queue;
        queue = [self playParametersQueueFromParams:self.playParametersList startAtIndexPath:indexPath];
        [self openToPlayQueueDescriptor:queue];
    }else{
        [self showAlbumsOrPlaylistsChartsDetailFromIndexPath:indexPath];
    }
}

# pragma mark - 选中cell 辅助操作方法
/**显示专辑/歌单详细*/
-(void)showAlbumsOrPlaylistsChartsDetailFromIndexPath:(NSIndexPath*) indexPath{
    Resource *resource = [self.chart.data objectAtIndex:indexPath.row];
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


#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.chart.data.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SongCell *cell = [tableView dequeueReusableCellWithIdentifier:songId];
    cell.song = [self.songs objectAtIndex:indexPath.row];
    cell.numberLabel.text = [NSString stringWithFormat:@"%.2ld",indexPath.row+1];
    return cell;
}



/**内地无MV 排行数据, 请求香港地区*/
//- (void) requestHongKongMVData{
//    NSString *path = @"https://api.music.apple.com/v1/catalog/hk/charts?types=music-videos";
//    NSURLRequest *request = [self createRequestWithURLString:path setupUserToken:NO];
//    [self dataTaskWithRequest:request handler:^(NSDictionary *json, NSHTTPURLResponse *response) {
//        if (json) {
//            self.root = [self serializationJSON:json];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.collectionView reloadData];
//                [self.collectionView.mj_header endRefreshing];
//            });
//        }
//    }];
//}

/**加载下一页数据*/
-(void) loadNextPage:(NSString*) nextHref{
    if (nextHref != NULL) {
        NSURLRequest *request = [self createRequestWithHref:nextHref];
        Log(@"next=%@",nextHref);
        [self dataTaskWithRequest:request handler:^(NSDictionary *json, NSHTTPURLResponse *response) {
//            NSArray<Chart*> *temp = [self serializationJSON:json];
//
//            //添加新的数据
//            Chart *oldChart = self.root.next;
//            Chart *newChart = temp.firstObject;
//            oldChart.next = newChart.next;
//            oldChart.data = [oldChart.data arrayByAddingObjectsFromArray:newChart.data];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.collectionView reloadData];
//                [self.collectionView.mj_footer endRefreshing];
//            });
        }];
    }
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
        layout.minimumInteritemSpacing = 20;   //列距
        layout.minimumLineSpacing = 20;        //行距
        CGFloat w = CGRectGetWidth(self.view.frame)-40;
        CGFloat h = w*1.5;
        [layout setItemSize:CGSizeMake(w, h)];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;

        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = UIColor.whiteColor;

        [_collectionView registerClass:ResourceCell.class forCellWithReuseIdentifier:cellId];

        //上拉加载更多
        __weak typeof(self) weakSelf = self;
        _collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{

            if (weakSelf.chart.next) {
                [self loadNextPage:weakSelf.chart.next];
            }else{
                [weakSelf.collectionView.mj_footer endRefreshingWithNoMoreData];
            }
        }];
    }
    return _collectionView;
}

-(PlayerViewController *)playerVC{
    if (!_playerVC) {
        _playerVC = [PlayerViewController sharePlayerViewController];
    }
    return _playerVC;
}
-(NSArray<Song *> *)songs{
    if (!_songs) {
        NSMutableArray<Song*> *temp = NSMutableArray.new;
        for (Resource *resource in self.chart.data) {
            Song *song = [Song instanceWithResource:resource];
            [temp addObject:song];
        }
        _songs = temp;
    }
    return _songs;
}

-(NSArray<NSDictionary *> *)playParametersList{
    if (!_playParametersList) {
        NSMutableArray<NSDictionary*> *temp = [NSMutableArray array];
        for (Resource *resource in self.chart.data) {
            if ([resource.attributes valueForKey:@"playParams"]) {
                [temp addObject:[resource.attributes valueForKey:@"playParams"]];
            }
        }
        _playParametersList = temp;
    }
    return _playParametersList;
}


@end
