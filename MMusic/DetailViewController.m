//
//  DetailViewController.m
//  MMusic
//
//  Created by Magician on 2018/3/9.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <UIImageView+WebCache.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MBProgressHUD.h>

//view & controller
#import "DetailViewController.h"
#import "PlayerViewController.h"
#import "HeaderView.h"
#import "SongCell.h"

//model & tool
#import "Playlist.h"
#import "Artwork.h"
#import "Album.h"
#import "Song.h"
#import "EditorialNotes.h"
#import "RequestFactory.h"
#import "PersonalizedRequestFactory.h"

@interface DetailViewController ()<UITableViewDelegate,UITableViewDataSource>
/**顶部视图*/
@property(nonatomic, strong) HeaderView *header;
@property(nonatomic, strong) UITableView *tableView;
//播放器视图控制器
@property(nonatomic, strong) PlayerViewController *playerVC;
@property(nonatomic, strong) MBProgressHUD *hud;

//data
@property(nonatomic, strong) NSArray<Song*> *songs;
@property(nonatomic, strong) NSArray<MPMusicPlayerPlayParameters*> *prameters;
@property(nonatomic, strong) MPMusicPlayerPlayParametersQueueDescriptor *prametersQueue;
@end

@implementation DetailViewController

static NSString *const cellReuseIdentifier = @"detailCellReuseId";

- (instancetype)initWithAlbum:(Album *)album{
    if (self = [super init]) {
        self.album = album;
    }
    return self;
}
- (instancetype)initWithPlaylist:(Playlist *)playlist{
    if (self = [super init]) {
        self.playlist = playlist;
    }
    return self;
}
- (instancetype)initWithObject:(id)object{
    if (self = [super init]) {
        if ([object isKindOfClass:Album.class]) {
            self.album = (Album*) object;
        }
        if ([object isKindOfClass:Playlist.class]) {
            self.playlist = (Playlist*) object;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    //数据请求(专辑/列表)
    [self requestData];
    //表视图
    self.tableView = ({
        UITableView *view = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [view registerClass:[SongCell class] forCellReuseIdentifier:cellReuseIdentifier];
        view.dataSource = self;
        view.delegate = self;
        view.separatorColor = UIColor.whiteColor;
        view;
    });

    //表头视图(不是节头)
    self.header = ({
        HeaderView *view = [[HeaderView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 200)];
        view.backgroundColor = UIColor.whiteColor;

        view;
    });

    self.tableView.tableHeaderView = self.header;
    [self.view addSubview:self.tableView];

    //更新 正在播放项目指示
    __weak typeof(self) weakSelf = self;
    self.playerVC.nowPlayingItem = ^(MPMediaItem *item) {
        NSString *nowPlaySongID = item.playbackStoreID;

        //遍历当前songs 列表, 找到id相匹配的 song和song所在的cell
        for (Song *song in weakSelf.songs) {
            NSString *songID = [song.playParams objectForKey:@"id"];

            NSIndexPath *path= [NSIndexPath indexPathForRow:[weakSelf.songs indexOfObject:song] inSection:0];
            SongCell *cell = [weakSelf.tableView cellForRowAtIndexPath:path];
            UIColor *blue = [UIColor blueColor];
            //修改在正在播放的song cell 颜色
            if ([songID isEqualToString:nowPlaySongID]) {
                [UIView animateWithDuration:1 animations:^{
                    [cell.sortLabel setTextColor:blue];
                    [cell.songNameLabel setTextColor:blue];
                    [cell.artistLabel setTextColor:blue];
                }];

            }else{
                //上一次播放的cell 改回原来的颜色
                if (CGColorEqualToColor(blue.CGColor, cell.songNameLabel.textColor.CGColor)) {
                    [UIView animateWithDuration:1 animations:^{
                        [cell.sortLabel setTextColor:[UIColor grayColor]];
                        [cell.songNameLabel setTextColor:[UIColor blackColor]];
                        [cell.artistLabel setTextColor:[UIColor grayColor]];
                    }];
                }
            }
        }
    };

}

//显示专辑或者播放列表 头部信息视图
- (void)viewDidAppear:(BOOL)animated{

    //封面海报
    Artwork *artowrk = self.album ? self.album.artwork : self.playlist.artwork;
    NSString *path = IMAGEPATH_FOR_URL(artowrk.url);
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    if (image) {
        [self.header.artworkView setImage:image];
    }else{
        CGFloat w = CGRectGetWidth(self.header.artworkView.bounds);
        CGFloat h = w;
        NSString *urlPath = [self stringReplacingOfString:artowrk.url height:h width:w];
        [self.header.artworkView sd_setImageWithURL:[NSURL URLWithString:urlPath] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            //图片缓存入内存
            BOOL sucess = [[NSFileManager defaultManager] createFileAtPath:path contents:UIImagePNGRepresentation(image) attributes:nil];
            //存入失败, 删除
            if (sucess == NO) [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }];
    }
    // 专辑或播放列表信息
    self.header.nameLabel.text = _album ? _album.name : _playlist.name;
    self.header.desc.text      = _album ? _album.artistName : _playlist.desc.standard;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/**请求数据*/
- (void) requestData{
    RequestFactory *factory = [RequestFactory requestFactory];
    NSURLRequest *request ;
    NSString *identitier = self.album ? [self.album.playParams objectForKey:@"id"] : [self.playlist.playParams objectForKey:@"id"];
    if (self.album) {
        request = [factory createRequestWithType:RequestAlbumType resourceIds:@[identitier,]];
    }else if (self.playlist){
        request = [factory createRequestWithType:RequestPlaylistType resourceIds:@[identitier,]];
    }

    [self dataTaskWithdRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error && data) {
            NSDictionary *json = [self serializationDataWithResponse:response data:data error:error];
            self.songs = [self serializationJSON:json];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    }];
}
/**解析返回的JSON 数据*/
- (NSArray*) serializationJSON:(NSDictionary*)json{
    NSMutableArray<Song*> *songList = [NSMutableArray array];
    //播放参数
    NSMutableArray<MPMusicPlayerPlayParameters*> *playParameters = [NSMutableArray array];
    for (NSDictionary *temp in [json objectForKey:@"data"]) {
        NSDictionary *relationships = [temp objectForKey:@"relationships"];
        relationships = [relationships objectForKey:@"tracks"];
        for (NSDictionary *songDict in [relationships objectForKey:@"data"]) {
            Song *song = [Song instanceWithDict:[songDict objectForKey:@"attributes"]];
            [songList addObject:song];

            //获取播放参数
            MPMusicPlayerPlayParameters *parameters = [[MPMusicPlayerPlayParameters alloc] initWithDictionary:song.playParams];
            [playParameters addObject:parameters];
        }
    }
    //设置播放队列
    self.prameters = playParameters;
    self.prametersQueue = [[MPMusicPlayerPlayParametersQueueDescriptor alloc] initWithPlayParametersQueue:playParameters];;
    return songList;
}

-(void) moreActive:(UIButton*) button{
    Song *song = [self.songs objectAtIndex:button.tag];
    NSString *songID = [song.playParams objectForKey:@"id"];

    UIAlertAction *nextPlay = [UIAlertAction actionWithTitle:@"下一首播放" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        MBProgressHUD *hud = self.hud;
        MPMusicPlayerPlayParameters *paramters = [[MPMusicPlayerPlayParameters alloc] initWithDictionary:song.playParams];
        MPMusicPlayerPlayParametersQueueDescriptor *queueDes;
        queueDes = [[MPMusicPlayerPlayParametersQueueDescriptor alloc] initWithPlayParametersQueue:@[paramters,]];
        [self.playerVC.playerController prependQueueDescriptor:queueDes];
        [hud hideAnimated:YES afterDelay:1.0f];
        self.hud = nil;  //赋值空, 下一使用重新添加到View中
    }];

    UIAlertAction *nowPlay = [UIAlertAction actionWithTitle:@"播放" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        MBProgressHUD *hud = self.hud;
        MPMusicPlayerPlayParameters *paramters = [[MPMusicPlayerPlayParameters alloc] initWithDictionary:song.playParams];
        [self.prametersQueue setStartItemPlayParameters:paramters];
        [self.playerVC.playerController setQueueWithDescriptor:self.prametersQueue];
        [self.playerVC.playerController play];
        [hud hideAnimated:YES afterDelay:1.0f];
        self.hud = nil;
    }];

    PersonalizedRequestFactory *factort = [PersonalizedRequestFactory personalizedRequestFactory];
    UIAlertAction *love = [UIAlertAction actionWithTitle:@"喜欢" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        MBProgressHUD *hud = self.hud;
        //PUT
        NSURLRequest *request = [factort createManageRatingsRequestWithType:AddSongRatingsType resourceIds:@[songID,]];
        [self dataTaskWithdRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            Log(@"statusCode:%ld",((NSHTTPURLResponse*)response).statusCode);
            [hud performSelectorOnMainThread:@selector(hideAnimated:) withObject:@YES waitUntilDone:NO];
            self.hud = nil;
        }];

        NSString *url =@"https://api.music.apple.com/v1/me/library?ids[songs]=280911996";
        NSMutableURLRequest *addLib = (NSMutableURLRequest*)[factort createRequestWithURLString:url setupUserToken:YES];
        [addLib setHTTPMethod:@"POST"];
        [self dataTaskWithdRequest:addLib completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (!error) {
                Log(@"lib status=%ld",((NSHTTPURLResponse*)response).statusCode);
            }
        }];
    }];

    UIAlertAction *notLove = [UIAlertAction actionWithTitle:@"不喜欢" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        MBProgressHUD *hud = self.hud;
        //DELETE
        NSURLRequest *request = [factort createManageRatingsRequestWithType:DeleteSongRatingsType resourceIds:@[songID,]];
        [self dataTaskWithdRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            Log(@"statusCode:%ld",((NSHTTPURLResponse*)response).statusCode);
            [hud performSelectorOnMainThread:@selector(hideAnimated:) withObject:@YES waitUntilDone:NO];
            self.hud = nil;
        }];
    }];

    //取消
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"cacel" style:UIAlertActionStyleCancel handler:nil];

    NSString *title = [NSString stringWithFormat:@"歌曲:%@ -- %@",song.name,song.artistName];
    UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertCtr addAction:nextPlay];
    [alertCtr addAction:nowPlay];
    [alertCtr addAction:love];
    [alertCtr addAction:notLove];
    [alertCtr addAction:cancel];

    [self presentViewController:alertCtr animated:YES completion:NULL];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.songs.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SongCell *cell = (SongCell*)[tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier forIndexPath:indexPath];
    // Configure the cell...

    //song info
    Song *song = [self.songs objectAtIndex:indexPath.row];
    cell.sortLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row+1];
    cell.songNameLabel.text = song.name;
    cell.artistLabel.text = song.artistName;

    //绑定Tag 用于获取选中了那首歌曲 index
    [cell.moreButton setTag:indexPath.row];
    [cell.moreButton addTarget:self action:@selector(moreActive:) forControlEvents:UIControlEventTouchUpInside];

    //判断 当前cell显示的 与正在播放的item 是否为同一个,
    NSString *nowPlaySongID = self.playerVC.playerController.nowPlayingItem.playbackStoreID;
    NSString *cellSongID = [song.playParams objectForKey:@"id"];

    //不相同,把原来改色的cell恢复颜色,
    if (![nowPlaySongID isEqualToString:cellSongID]) {
        [cell.sortLabel setTextColor:[UIColor grayColor]];
        [cell.songNameLabel setTextColor:[UIColor blackColor]];
        [cell.artistLabel setTextColor:[UIColor grayColor]];
    }else{
        [cell.sortLabel setTextColor:[UIColor blueColor]];
        [cell.songNameLabel setTextColor:[UIColor blueColor]];
        [cell.artistLabel setTextColor:[UIColor blueColor]];
    }
    return cell;
}

#pragma mark - tableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    //现在播放的项目 和现在选择的项目是同一个, 弹出视图, 不从头播放
    NSString *nowId = self.playerVC.playerController.nowPlayingItem.playbackStoreID;
    NSString *selectorID = [[self.songs objectAtIndex:indexPath.row].playParams objectForKey:@"id"];
    if (![nowId isEqualToString:selectorID]) {
        [self.prametersQueue setStartItemPlayParameters:[self.prameters objectAtIndex:indexPath.row]];
        [self.playerVC.playerController setQueueWithDescriptor:self.prametersQueue];
        [self.playerVC.playerController prepareToPlay];

        [self.playerVC setNowPlaySong:[self.songs objectAtIndex:indexPath.row]];
        [self.playerVC setSongs:self.songs];
    }

    //显示视图
    [self presentViewController:self.playerVC animated:YES completion:nil];

}

#pragma mark Layz
-(PlayerViewController *)playerVC{
    if (!_playerVC) {
        _playerVC = PlayerViewController.new;
        [_playerVC.playerController setQueueWithDescriptor:self.prametersQueue];
    }
    return _playerVC;
}

@end
