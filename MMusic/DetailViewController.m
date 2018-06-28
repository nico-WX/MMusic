//
//  DetailViewController.m
//  MMusic
//
//  Created by Magician on 2018/3/9.
//  Copyright © 2018年 com.😈. All rights reserved.

//pod /sy
#import <UIImageView+WebCache.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MBProgressHUD.h>
#import <Masonry.h>
#import <MJRefresh.h>

//vc
#import "DetailViewController.h"
#import "PlayerViewController.h"

//view
#import "DetailHeaderView.h"
#import "SongCell.h"

//model & tool
#import "MusicKit.h"

#import "ResponseRoot.h"
#import "Playlist.h"
#import "Artwork.h"
#import "Album.h"
#import "Song.h"
#import "EditorialNotes.h"
#import "Resource.h"

@interface DetailViewController ()<UITableViewDelegate,UITableViewDataSource>
/**头视图*/
@property(nonatomic, strong) DetailHeaderView *header;
//专辑,播放列表等初始数据
@property(nonatomic, strong) Resource *resource;
//songs 初始化列表数据
@property(nonatomic, strong) ResponseRoot *responseRoot;

//播放器视图控制器
@property(nonatomic, strong) PlayerViewController *playerVC;

//data 数据在请求数据方法中 初始化
@property(nonatomic, strong) NSArray<Song*> *songs;
@property(nonatomic, strong) NSArray<MPMusicPlayerPlayParameters*> *prameters;
@property(nonatomic, strong) MPMusicPlayerPlayParametersQueueDescriptor *prametersQueue;
@end

@implementation DetailViewController
@synthesize tableView = _tableView;
static NSString *const cellReuseIdentifier = @"detailCellReuseId";

-(instancetype)initWithResource:(Resource *)resource{
    if (self = [super init]) {
        _resource = resource;
    }
    return self;
}
-(instancetype)initWithResponseRoot:(ResponseRoot *)responseRoot{
    if (self = [super init]) {
        _responseRoot = responseRoot;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self.tableView];
    //数据请求(专辑/列表)
    if (self.resource) {
        [self requestDataWithResource:self.resource];

        //通过播放列表等 初始化, 有头部
        [self.tableView setTableHeaderView:self.header];
    }else{

        //通过Songs ResponseRoot 没有头视图
        NSMutableArray *temp = [NSMutableArray array];
        for (Resource *resource in self.responseRoot.data) {
            [temp addObject:[Song instanceWithResource:resource]];
        }
        self.songs = temp;
        [self.tableView reloadData];
        self.tableView.mj_footer = [MJRefreshBackFooter footerWithRefreshingBlock:^{
            if (self.responseRoot.next) {
                [self loadNextPageDataWithHref:self.responseRoot.next];
            }else{
                [self->_tableView.mj_footer endRefreshingWithNoMoreData];
            }
        }];
    }

    //播放的item 滚动到中间(或可视范围)
    [[NSNotificationCenter defaultCenter] addObserverForName:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        for (Song *song in self.songs) {
            if ([song isEqualToMediaItem:self.playerVC.playerController.nowPlayingItem]) {
                NSUInteger index = [self.songs indexOfObject:song];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            }
        }
    }];

}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    //设置UI
    //封面海报
    if ([self.resource.attributes valueForKeyPath:@"artwork"]) {
        Artwork *art = [Artwork instanceWithDict:[self.resource.attributes valueForKeyPath:@"artwork"]];
        [self showImageToView:self.header.artworkView withImageURL:art.url cacheToMemory:YES];
    }

    [self.resource .attributes enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([key isEqualToString:@"artwork"]) {

            *stop = YES;
        }
    }];

    //name
    if ([self.resource.attributes valueForKeyPath:@"name"]) {
        self.header.nameLabel.text = [self.resource.attributes valueForKeyPath:@"name"];
    }

    //des
    if ([self.resource.attributes valueForKeyPath:@"editorialNotes"]) {
        EditorialNotes *notes = [EditorialNotes instanceWithDict:[self.resource.attributes valueForKeyPath:@"editorialNotes"]];
        NSString *text = notes.standard ? notes.standard : notes.shortNotes;
        self.header.desc.text = text;
    } else if ([self.resource.attributes valueForKeyPath:@"artistName"]){   //部分没有editorialNotes  使用artist
        self.header.desc.text = [self.resource.attributes valueForKeyPath:@"artistName"];
    }
    // 歌单中的 editorialNotes 键名为:description
    if ([self.resource.attributes valueForKeyPath:@"description"]) {
        EditorialNotes *notes = [EditorialNotes instanceWithDict:[self.resource.attributes valueForKeyPath:@"description"]];
        NSString *text = notes.standard ? notes.standard : notes.shortNotes;
        self.header.desc.text = text;
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    UIView *superview = self.view;
    //与父视图大小一致
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(superview).insets(UIEdgeInsetsZero);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.songs.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SongCell *cell = (SongCell*)[tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier forIndexPath:indexPath];

    //song info
    cell.song = [self.songs objectAtIndex:indexPath.row];
    cell.numberLabel.text = [NSString stringWithFormat:@"%02ld",indexPath.row+1];
    return cell;
}


#pragma mark - tableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //现在播放的项目 和现在选择的项目是同一个, 弹出视图, 不从头播放
    MPMediaItem *item = self.playerVC.playerController.nowPlayingItem;
    Song *song = [self.songs objectAtIndex:indexPath.row];

    if (![song isEqualToMediaItem:item]) {
        [self.prametersQueue setStartItemPlayParameters:[self.prameters objectAtIndex:indexPath.row]];
        [self.playerVC.playerController setQueueWithDescriptor:self.prametersQueue];
        [self.playerVC.playerController prepareToPlay];
    }
    [self.playerVC showFromViewController:self withSongs:self.songs startItem:song];

}

#pragma mark getter
-(PlayerViewController *)playerVC{
    if (!_playerVC) {
        _playerVC = PlayerViewController.new;
        //设置 播放队列
        [_playerVC.playerController setQueueWithDescriptor:self.prametersQueue];
    }
    return _playerVC;
}

-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [_tableView registerClass:[SongCell class] forCellReuseIdentifier:cellReuseIdentifier];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView setRowHeight:44.0f];

        UILongPressGestureRecognizer *longGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(gestureActive:)];
        [_tableView addGestureRecognizer:longGR];
    }
    return _tableView;
}
-(DetailHeaderView *)header{
    if (!_header) {
        //header
        _header = [[DetailHeaderView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 150)];
        _header.backgroundColor = UIColor.whiteColor;
    }
    return _header;
}
-(MPMusicPlayerPlayParametersQueueDescriptor *)prametersQueue{
    if (!_prametersQueue) {
        NSMutableArray *temp = [NSMutableArray array];
        for (Song *song in self.songs) {
            [temp addObject: [[MPMusicPlayerPlayParameters alloc] initWithDictionary:song.playParams]];
        }
        _prametersQueue = [[MPMusicPlayerPlayParametersQueueDescriptor alloc] initWithPlayParametersQueue:temp];
    }
    return _prametersQueue;
}

#pragma mark - Helper

/**请求数据*/
- (void) requestDataWithResource:(Resource*) resource{

    if ([self.resource.type isEqualToString:@"library-playlists"]) {
        [[MusicKit new].api.library resource:@[self.resource.identifier,] byType:CLibraryPlaylists callBack:^(NSDictionary *json, NSHTTPURLResponse *response) {
            self.songs = [self serializationJSON:json];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
    }else{
        NSURLRequest *request = [self createRequestWithHref:self.resource.href];
        [self dataTaskWithRequest:request handler:^(NSDictionary *json, NSHTTPURLResponse *response) {
            self.songs = [self serializationJSON:json];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
    }

}
-(void) loadNextPageDataWithHref:(NSString*) href{
    NSURLRequest *request = [self createRequestWithHref:href];
    [self dataTaskWithRequest:request handler:^(NSDictionary *json, NSHTTPURLResponse *response) {
        json =[json valueForKeyPath:@"results.songs"];

        //覆盖next url,  增加song
        self.responseRoot.next = [json valueForKey:@"next"];
        for (NSDictionary *dict in [json valueForKey:@"data"]) {
            Song *song = [Song instanceWithDict:[dict valueForKey:@"attributes"]];
            self.songs = [self.songs arrayByAddingObject:song];
        }
        self.prametersQueue = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView.mj_footer endRefreshing];
            [self.tableView reloadData];
        });
    }];
}

/**解析返回的JSON 数据*/
- (NSArray<Song*>*) serializationJSON:(NSDictionary*)json{
    NSMutableArray<Song*> *songList = [NSMutableArray array];
    for (NSDictionary *temp in [json objectForKey:@"data"]) {
        NSArray *tracks = [temp valueForKeyPath:@"relationships.tracks.data"];
        for (NSDictionary *songDict in tracks) {
            Song *song = [Song instanceWithDict:[songDict objectForKey:@"attributes"]];
            [songList addObject:song];
        }
    }
    return songList;
}

-(void) gestureActive:(UILongPressGestureRecognizer*) gesture{

    //确认选中 的Cell
    if (gesture.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [gesture locationInView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: point];
        if (indexPath==nil) return;

        Song *song = [self.songs objectAtIndex:indexPath.row];
        //获取歌曲ID
        NSString *songID = [song.playParams objectForKey:@"id"];

        //下一首
        UIAlertAction *nextPlay = [UIAlertAction actionWithTitle:@"下一首播放" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //播放队列
            MPMusicPlayerPlayParameters *paramters = [[MPMusicPlayerPlayParameters alloc] initWithDictionary:song.playParams];
            MPMusicPlayerPlayParametersQueueDescriptor *queueDes;
            queueDes = [[MPMusicPlayerPlayParametersQueueDescriptor alloc] initWithPlayParametersQueue:@[paramters,]];
            //插入当前队列
            [self.playerVC.playerController prependQueueDescriptor:queueDes];
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
            hud.mode = MBProgressHUDModeCustomView;
            hud.label.text = @"OK";
            [hud hideAnimated:YES afterDelay:1.5];
        }];

        MusicKit *music = [MusicKit new];
        UIAlertAction *notLove = [UIAlertAction actionWithTitle:@"不喜欢" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [music.api.library deleteRating:songID byType:CRatingSongs callBack:^(NSDictionary *json, NSHTTPURLResponse *response) {
                [self showHUDToView:self.tableView withResponse:(NSHTTPURLResponse*)response];
            }];
        }];

        UIAlertAction *love = [UIAlertAction actionWithTitle:@"喜欢" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [music.api.library addRating:songID byType:CRatingSongs value:1 callBack:^(NSDictionary *json, NSHTTPURLResponse *response) {
                [self showHUDToView:self.tableView withResponse:(NSHTTPURLResponse*) response];
            }];
        }];

        //取消
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:nil];

        //提醒视图
        NSString *title = [NSString stringWithFormat:@"歌曲: %@ ",song.name];
        UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertCtr addAction:nextPlay];
        [alertCtr addAction:love];
        [alertCtr addAction:notLove];
        [alertCtr addAction:cancel];

        [self presentViewController:alertCtr animated:YES completion:NULL];
    }
}

/**显示HUD 到指定的视图中*/
-(void) showHUDToView:(UIView*) view withResponse:(NSHTTPURLResponse*) response{
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
        
        UIImage *image;
        //200 段
        if (response.statusCode/10 == 20) {
            image = [[UIImage imageNamed:@"Check"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            hud.label.text = @"OK";
        }
        //400 段
        if (response.statusCode/10 == 40) {
            hud.label.text = @"请求失败";
        }
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        hud.customView = imageView;
        hud.mode = MBProgressHUDModeCustomView;
        [hud hideAnimated:YES afterDelay:1.5];
    });
}



@end
