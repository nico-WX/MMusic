//
//  DetailViewController.m
//  MMusic
//
//  Created by Magician on 2018/3/9.
//  Copyright © 2018年 com.😈. All rights reserved.
//
#import <VBFPopFlatButton.h>
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
#import "Resource.h"

@interface DetailViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, strong) Resource *resource;
/**顶部视图*/
@property(nonatomic, strong) HeaderView *header;
@property(nonatomic, strong) UITableView *tableView;
//播放器视图控制器
@property(nonatomic, strong) PlayerViewController *playerVC;
//data 数据在请求数据方法中 初始化
@property(nonatomic, strong) NSArray<Song*> *songs;
@property(nonatomic, strong) NSArray<MPMusicPlayerPlayParameters*> *prameters;
@property(nonatomic, strong) MPMusicPlayerPlayParametersQueueDescriptor *prametersQueue;
@end

@implementation DetailViewController

static NSString *const cellReuseIdentifier = @"detailCellReuseId";

-(instancetype)initWithResource:(Resource *)resource{
    if (self = [super init]) {
        _resource = resource;
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

    //表头视图
    self.header = [[HeaderView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 150)];
    self.header.backgroundColor = UIColor.whiteColor;

    self.tableView.tableHeaderView = self.header;
    [self.view addSubview:self.tableView];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //封面海报
    if ([self.resource.attributes valueForKeyPath:@"artwork"]) {
        Artwork *art = [Artwork instanceWithDict:[self.resource.attributes valueForKeyPath:@"artwork"]];
        [self showImageToView:self.header.artworkView withImageURL:art.url cacheToMemory:YES];
    }

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.songs.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SongCell *cell = (SongCell*)[tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier forIndexPath:indexPath];
    // Configure the cell...

    //安装长按手势识别器, 弹出操作菜单
    UILongPressGestureRecognizer *longGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(gestureActive:)];
    [cell addGestureRecognizer:longGR];

    //song info
    Song *song = [self.songs objectAtIndex:indexPath.row];
    cell.songNameLabel.text = song.name;
    cell.artistLabel.text = song.artistName;
    [self showImageToView:cell.artworkView withImageURL:song.artwork.url cacheToMemory:NO];

    //判断 当前cell显示的 与正在播放的item 是否为同一个,
    NSString *nowPlaySongID = self.playerVC.playerController.nowPlayingItem.playbackStoreID;
    NSString *cellSongID = [song.playParams objectForKey:@"id"];

    //不相同,把原来改色的cell恢复颜色,<重用遗留>
    if (![nowPlaySongID isEqualToString:cellSongID]) {
        [cell.songNameLabel setTextColor:[UIColor blackColor]];
        [cell.artistLabel setTextColor:[UIColor grayColor]];
    }else{
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
    }

    [self.playerVC setNowPlaySong:[self.songs objectAtIndex:indexPath.row]];
    [self.playerVC setSongs:self.songs];
    //显示视图
    [self presentViewController:self.playerVC animated:YES completion:nil];

}
//定行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.0f;
}

#pragma mark Layz
-(PlayerViewController *)playerVC{
    if (!_playerVC) {
        _playerVC = PlayerViewController.new;
        //设置 播放队列
        [_playerVC.playerController setQueueWithDescriptor:self.prametersQueue];

        //更新 正在播放项目指示
        __weak typeof(self) weakSelf = self;
        _playerVC.nowPlayingItem = ^(MPMediaItem *item) {
            NSString *nowPlaySongID = item.playbackStoreID;
            //遍历当前songs 列表, 找到id相匹配的 song和song所在的cell
            for (Song *song in weakSelf.songs) {
                NSString *songID = [song.playParams objectForKey:@"id"];
                NSIndexPath *path= [NSIndexPath indexPathForRow:[weakSelf.songs indexOfObject:song] inSection:0];
                SongCell *cell = [weakSelf.tableView cellForRowAtIndexPath:path];
                UIColor *blue = [UIColor blueColor];

                //修改在正在播放的song cell 颜色
                if ([songID isEqualToString:nowPlaySongID]) {

                    [cell.songNameLabel setTextColor:blue];
                    [cell.artistLabel setTextColor:blue];
                }else{
                    //上一次播放的cell 改回原来的颜色  通过比对颜色,
                    if (CGColorEqualToColor(blue.CGColor, cell.songNameLabel.textColor.CGColor)) {
                        [cell.songNameLabel setTextColor:[UIColor blackColor]];
                        [cell.artistLabel setTextColor:[UIColor grayColor]];
                    }
                }
            }
        };
    }
    return _playerVC;
}

/**请求数据*/
- (void) requestData{
    NSURLRequest *request = [[RequestFactory requestFactory] createRequestWithHerf:self.resource.href];
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
- (NSArray<Song*>*) serializationJSON:(NSDictionary*)json{
    NSMutableArray<Song*> *songList = [NSMutableArray array];
    //播放参数
    NSMutableArray<MPMusicPlayerPlayParameters*> *playParameters = [NSMutableArray array];
    for (NSDictionary *temp in [json objectForKey:@"data"]) {
        NSArray *tracks = [temp valueForKeyPath:@"relationships.tracks.data"];
        for (NSDictionary *songDict in tracks) {
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

        PersonalizedRequestFactory *factort = [PersonalizedRequestFactory personalizedRequestFactory];
        UIAlertAction *notLove = [UIAlertAction actionWithTitle:@"不喜欢" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //DELETE
            NSURLRequest *request = [factort createManageRatingsRequestWithType:DeleteSongRatingsType resourceIds:@[songID,]];
            [self dataTaskWithdRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                [self showHUDToView:self.tableView withResponse:(NSHTTPURLResponse*)response];
            }];
        }];

        UIAlertAction *love = [UIAlertAction actionWithTitle:@"喜欢" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //PUT
            NSURLRequest *request = [factort createManageRatingsRequestWithType:AddSongRatingsType resourceIds:@[songID,]];
            [self dataTaskWithdRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
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
