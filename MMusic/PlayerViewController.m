//
//  PlayerViewController.m
//  MMusic
//
//  Created by Magician on 2018/3/11.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <Masonry.h>

#import "PlayerViewController.h"
#import "PlayerView.h"
#import "PlayProgressView.h"
#import "PlayControllerView.h"

#import "NSObject+Tool.h"
#import "Artwork.h"
#import "Song.h"
#import "MusicVideo.h"

#import "DBTool.h"
#import "TracksModel.h"
#import "ArtistsModel.h"

@interface PlayerViewController ()<MPSystemMusicPlayerController>
/**播放器UI*/
@property(nonatomic, strong) PlayerView *playerView;
/**定时获取播放时间,更新UI*/
@property(nonatomic, strong) NSTimer *timer;
/**歌曲列表*/
@property(nonatomic, strong) NSArray<Song*> *songs;
/**播放队列*/
@property(nonatomic, strong)MPMusicPlayerPlayParametersQueueDescriptor *parametersQueue;
@end


static PlayerViewController *_instance;

@implementation PlayerViewController

#pragma mark - 初始化 / 单例
+ (instancetype)sharePlayerViewController{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_instance) {
            _instance = [[self alloc] init];
        }
    });
    return _instance;
}
+(instancetype)allocWithZone:(struct _NSZone *)zone{
    //防止同时访问
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_instance){
            _instance = [super allocWithZone:zone];
        }
    });
    return _instance;
}
-(instancetype)init{
    if (self = [super init]) {
        //不在viewDidLoad 中添加
        [self.view addSubview:self.playerView];
        [self.timer fire];
    }
    return self;
}
-(id)copyWithZone:(NSZone *)zone{
    return _instance;
}
-(id)mutableCopyWithZone:(NSZone *)zone{
    return _instance;
}

#pragma mark - cycle
- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self updateUIForNowPlayItem:self.playerController.nowPlayingItem];
}

- (void)dealloc{
    [self.playerController endGeneratingPlaybackNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 更新UI信息
-(void)updateUIForNowPlayItem:(MPMediaItem*) item{



    //主线程更新
    dispatch_async(dispatch_get_main_queue(), ^{

        /**
         1.判断当前有没有加载Song 对象, 如果没有, 页面信息从系统获取
         2.0 : 如果没有,从系统获取页面信息
         2.1 : 从系统获取时, 需要识别是否为Apple版权的音乐,还是第三方添加的,Apple版权音乐直接通过ID获取Song 对象,更新信息
         2.2 : 第三方音乐直接获取数据,更新信息
         2.3 : (未完成: 第三方音乐, 通过音乐名称,和艺人, 在Apple 目录中搜索, 返回Song 对象)
         */

        //匹配数组中的song
        Song *song = [self songWithNowPlayingItem:item];
        if (!song) {
            //没有从当前数组中匹配到,可能是:(当前没有设置songs,或者当前没有播放,也可能是第三方音乐);
            if (item){
                //有Identifier 属于AppleMusic版权库音乐 请求Song对象
                NSString *identifier = item.playbackStoreID;
                Log(@"identi =%@",identifier);
                Log(@"id =%d",item.isCloudItem);


                if ((identifier) && (![identifier isEqualToString:@"0"])) { //有时为"0"
                    [self.playerView.heartIcon setEnabled:YES];
                    [MusicKit.new.api resources:@[identifier,] byType:CatalogSongs callBack:^(NSDictionary *json, NSHTTPURLResponse *response) {
                        if (json && response.statusCode == 200) {
                            [json enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                                NSMutableArray<Song*> *temp = [NSMutableArray array];
                                [(NSArray*)obj enumerateObjectsUsingBlock:^(id  _Nonnull songResource, NSUInteger idx, BOOL * _Nonnull stop) {
                                    [temp addObject:[Song instanceWithDict:[songResource objectForKey:@"attributes"]]];
                                }];
                                //添加到数组中
                                self.songs = self.songs ? [self.songs arrayByAddingObjectsFromArray:temp] : temp;
                                [self updateUIForNowPlayItem:item];
                            }];
                        }
                    }];

                }else{
                    //第三方音乐
                    [self.playerView.heartIcon setOn:NO animated:YES];  //开关ON
                    [self.playerView.heartIcon setEnabled:NO];          //关闭开关交互, 不能添加喜欢
                    //[self showHUDToMainWindowFromText:@"正在播放第三方音乐"];


                    int duration = item.playbackDuration;
                    NSString *durationString = [NSString stringWithFormat:@"%02d:%02d",duration/60,duration%60];
                    [self.playerView.durationTime setText:durationString];
                    [self.playerView.songNameLabel setText:item.title];
                    [self.playerView.artistLabel setText:item.artist];

                    // 第三方音乐可以从内部获取专辑封面
                    CGSize size = self.playerView.artworkView.bounds.size;
                    [self.playerView.artworkView setImage:[item.artwork imageWithSize:size]];
                }
            }else{
                //没有在播放
                [self showHUDToMainWindowFromText:@"系统播放器没有加载音乐"];
                [self.playerView.heartIcon setEnabled:NO];
                return ;
            }
        }else{
            //数组中有song
            [self.playerView.songNameLabel setText:song.name];
            [self.playerView.artistLabel setText:song.artistName];
            int duration = song.durationInMillis.intValue/1000;//秒
            NSString *durationStr = [NSString stringWithFormat:@"%02d:%02d",duration/60,duration%60];
            [self.playerView.durationTime setText: durationStr];
            [self showImageToView:self.playerView.artworkView withImageURL:song.artwork.url cacheToMemory:YES];
            //红心开关 状态查询,设置
            [self.playerView.heartIcon setEnabled:YES];
            [self heartFromSongIdentifier:[song.playParams objectForKey:@"id"]];
            //收集艺人信息, 填充艺人列表数据
            [self addArtistsToDataBaseFromSong:song];
        }
    });
}

#pragma mark - MPSystemMusicPlayerController
-(void)openToPlayQueueDescriptor:(MPMusicPlayerQueueDescriptor *)queueDescriptor{
    UIApplication *app = [UIApplication sharedApplication];
    NSURL *url = [NSURL URLWithString:@"Music:prefs:root=MUSIC"];
    if ([app canOpenURL:url]) {
        [app openURL:url options:@{} completionHandler:^(BOOL success) {
            [self.playerController setQueueWithDescriptor:queueDescriptor];
            [self.playerController play];
        }];
    }
}

#pragma mark - Instance Method
-(void)playSongs:(NSArray<Song *> *)songs startIndex:(NSUInteger)startIndex{
     self.songs = songs;

    //当前开始的与正在播放的比对
    Song *song = [self.songs objectAtIndex:startIndex];
    if ([song isEqualToMediaItem:self.playerController.nowPlayingItem]) {
        //选中的正在播放中, 不处理
    }else{
        MPMusicPlayerPlayParameters *parameter = [[MPMusicPlayerPlayParameters alloc] initWithDictionary:song.playParams];
        [self.parametersQueue setStartItemPlayParameters:parameter];
        [self.playerController setQueueWithDescriptor:self.parametersQueue];
        [self.playerController play];
    }
}
-(void)insertSongAtNextItem:(Song *)song{
    MPMusicPlayerPlayParameters *parameter = [[MPMusicPlayerPlayParameters alloc] initWithDictionary:song.playParams];
    MPMusicPlayerPlayParametersQueueDescriptor *queue = [[MPMusicPlayerPlayParametersQueueDescriptor alloc] initWithPlayParametersQueue:@[parameter,]];
    [self.playerController prependQueueDescriptor:queue];

    NSMutableArray<Song*> *array = [NSMutableArray arrayWithArray:self.songs];
    NSUInteger index = self.playerController.indexOfNowPlayingItem;
    //数据添加到指定位置
    if (self.songs.count >= index) {
        [array insertObject:song atIndex:++index]; //当前播放下标后面
        self.songs = array;
    }
}
-(void)insertSongAtEndItem:(Song *)song{
    MPMusicPlayerPlayParameters *parameter = [[MPMusicPlayerPlayParameters alloc] initWithDictionary:song.playParams];
    MPMusicPlayerPlayParametersQueueDescriptor *queue = [[MPMusicPlayerPlayParametersQueueDescriptor alloc] initWithPlayParametersQueue:@[parameter,]];
    [self.playerController appendQueueDescriptor:queue];

    //插入添加数据
    if (self.songs.count > 0) {
        self.songs = [self.songs arrayByAddingObject:song];
    }
}
-(void)playMusicVideos:(NSArray<MusicVideo *> *)mvs startIndex:(NSUInteger)startIndex{
    NSMutableArray<MPMusicPlayerPlayParameters*> *array = [NSMutableArray array];
    for (MusicVideo *mv in mvs) {
        [array addObject:[[MPMusicPlayerPlayParameters alloc] initWithDictionary:mv.playParams]];
    }
    MPMusicPlayerPlayParametersQueueDescriptor *queue = [[MPMusicPlayerPlayParametersQueueDescriptor alloc] initWithPlayParametersQueue:array];
    [queue setStartItemPlayParameters:[array objectAtIndex:startIndex]];
    [self openToPlayQueueDescriptor:queue];
}

#pragma mark - Helper
/**查找当前队列中匹配的song*/
-(nullable Song*)songWithNowPlayingItem:(MPMediaItem*)item{
    for (Song *song in self.songs) {
        if ([song isEqualToMediaItem:item]) {
            return song;
        }
    }
    return nil;
}

/**存储艺人信息 , 添加到数据库, 创建艺人列表*/
-(void)addArtistsToDataBaseFromSong:(Song*) song{
        if (song.artistName) {
            [MusicKit.new.api searchForTerm:song.artistName callBack:^(NSDictionary *json, NSHTTPURLResponse *response) {
                json = [[json valueForKeyPath:@"results.artists.data"] firstObject];
                dispatch_async(dispatch_get_main_queue(), ^{
                    ArtistsModel *artist = [ArtistsModel new];
                    artist.identifier = [json valueForKey:@"id"];
                    artist.name = song.artistName;

                    UIImage *image = self.playerView.artworkView.image;
                    if (!image) {
                        image = [self imageFromURL:song.artwork.url withImageSize:self.playerView.artworkView.frame.size];
                    }
                    artist.image = image;
                    [DBTool addArtists:artist];
                });
            }];
        }
}

/**获取歌曲rating 状态, 并设置 开关状态*/
-(void)heartFromSongIdentifier:(NSString*) identifier{
    if (identifier) {
        [MusicKit.new.api.library getRating:@[identifier,] byType:CRatingSongs callBack:^(NSDictionary *json, NSHTTPURLResponse *response) {
            BOOL love = (json && response.statusCode==200) ? YES : NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.playerView.heartIcon setOn:love animated:YES];
            });
        }];
    }
}

-(void)playButtonStateForPlaybackState:(MPMusicPlaybackState) state{
    switch (state) {
        case MPMusicPlaybackStatePaused:
        case MPMusicPlaybackStateStopped:
        case MPMusicPlaybackStateInterrupted:
            [self.playerView.play setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
            break;

        case MPMusicPlaybackStatePlaying:
        case MPMusicPlaybackStateSeekingForward:
        case MPMusicPlaybackStateSeekingBackward:
            [self.playerView.play setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
            break;
    }
}

#pragma mark - getter

-(MPMusicPlayerController *)playerController{
    if (!_playerController) {
        _playerController = [MPMusicPlayerController systemMusicPlayer];
        [_playerController beginGeneratingPlaybackNotifications];       //开启消息
        [self playButtonStateForPlaybackState:_playerController.playbackState];

        //注册通知
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        __weak typeof(self) weakSelf = self;
        // 监听播放项目改变
        [center addObserverForName:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            [weakSelf updateUIForNowPlayItem:weakSelf.playerController.nowPlayingItem];
        }];

        //播放状态;
        [center addObserverForName:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            [weakSelf playButtonStateForPlaybackState:weakSelf.playerController.playbackState];
        }];
    }
    return _playerController;
}

-(PlayerView *)playerView{
    if (!_playerView) {
        _playerView = [[PlayerView alloc] initWithFrame:self.view.bounds];

        //事件绑定
        [_playerView.progressView addTarget:self action:@selector(sliderChange:) forControlEvents:UIControlEventValueChanged];
        [_playerView.previous addTarget:self action:@selector(previous:) forControlEvents:UIControlEventTouchUpInside];
        [_playerView.play addTarget:self action:@selector(playOrPause:) forControlEvents:UIControlEventTouchUpInside];
        [_playerView.next addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchUpInside];
        [_playerView.heartIcon addTarget:self action:@selector(changeLove:) forControlEvents:UIControlEventTouchUpInside];

        //下滑隐藏控制器 手势
        UISwipeGestureRecognizer *gesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(closeViewController)];
        [gesture setDirection:UISwipeGestureRecognizerDirectionDown];
        [_playerView addGestureRecognizer:gesture];
    }
    return _playerView;
}

/** 定时获取当前播放时间*/
- (NSTimer *)timer{
    if (!_timer) {
        __weak typeof(self) weakSelf = self;
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
            //当前播放时间
            NSTimeInterval current = self->_playerController.currentPlaybackTime;//秒 self->
            int min = (int)current/60;
            int sec = (int)current%60;
            weakSelf.playerView.currentTime.text = [NSString stringWithFormat:@"%.2d:%.2d",min,sec];

            //更新进度条
            NSTimeInterval duration = weakSelf.playerController.nowPlayingItem.playbackDuration; //秒
            CGFloat value = (current/duration);
            [weakSelf.playerView.progressView setValue:value animated:YES];
        }];
    }
    return _timer;
}

#pragma mark - setter
-(void)setSongs:(NSArray<Song *> *)songs{
    if (_songs != songs) {
        _songs = songs;

        NSMutableArray<MPMusicPlayerPlayParameters*> *array = [NSMutableArray array];
        for (Song *song  in songs) {
            [array addObject:[[MPMusicPlayerPlayParameters alloc] initWithDictionary:song.playParams]];
        }
        self.parametersQueue = [[MPMusicPlayerPlayParametersQueueDescriptor alloc] initWithPlayParametersQueue:array];
    }
}


#pragma mark - Button Action
/**下滑手势*/
-(void) closeViewController{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//进度条拖拽事件
- (void)sliderChange:(UISlider*) slider{
    NSTimeInterval duration = self.playerController.nowPlayingItem.playbackDuration; //秒
    NSTimeInterval current = duration * slider.value;
    [self.playerController setCurrentPlaybackTime:current];

    int min = (int)current/60;
    int sec = (int)current%60;
    self.playerView.currentTime.text = [NSString stringWithFormat:@"%.2d:%.2d",min,sec];
}

//上一首
- (void)previous:(UIButton*) button{
    [self.playerController skipToPreviousItem];
    [self animationButton:button];
}

//播放或暂停
- (void)playOrPause:(UIButton*) button{
    [self animationButton:button];

    switch (self.playerController.playbackState) {
        case MPMusicPlaybackStatePlaying:
            [self.playerController pause];
            //[self.timer invalidate];
            [button setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
            break;

        case MPMusicPlaybackStatePaused:
        case MPMusicPlaybackStateStopped:
        case MPMusicPlaybackStateInterrupted:
            [self.timer fire];
            [self.playerController play];
            [button setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
            break;

            default:
            break;
    }
}

//下一首
-(void)next:(UIButton*) button{
    [self.playerController skipToNextItem];
    [self animationButton:button];
}

-(void) animationButton:(UIButton*) sender{
    [UIView animateWithDuration:0.2 animations:^{
        [sender setTransform:CGAffineTransformMakeScale(0.88, 0.88)];
    } completion:^(BOOL finished) {
        if (finished) {
            //恢复
            [UIView animateWithDuration:0.2 animations:^{
                [sender setTransform:CGAffineTransformIdentity];
            }];
        }
    }];
}

//红心按钮 添加喜欢或者取消喜欢
- (void)changeLove:(LOTAnimatedSwitch*) heart{

    NSString *identifier = self.playerController.nowPlayingItem.playbackStoreID; //[self.nowPlaySong.playParams objectForKey:@"id"];
    // 查询当前rating状态(不是基于当前按钮状态)  --> 操作
    [MusicKit.new.api.library getRating:@[identifier,] byType:CRatingSongs callBack:^(NSDictionary *json, NSHTTPURLResponse *response) {
        if (json && response.statusCode==200) {
            //当前为喜欢状态
            //取消喜欢 <DELETE>
            [self deleteRatingForSongId:identifier];
        }else{
            //当前没有添加为喜欢
            //添加喜欢 <PUT>
            //[self addRatingForSongId:identifier];
            [self addResourceToLibrary:identifier];
        }
    }];
}

-(void) deleteRatingForSongId:(NSString*)identifier{

    [MusicKit.new.api.library deleteRating:identifier byType:CRatingSongs callBack:^(NSDictionary *json, NSHTTPURLResponse *response) {
        if (response.statusCode/10 == 20) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.playerView.heartIcon setOn:NO animated:YES];
            });
        }
    }];
}


/**添加到播放列表中,
 0.添加rating, 成功后,执行添加到库播放列表中
 1.先查询播放列表id
 2.添加到播放列表中,
 3.存储到数据库中
 */
-(void) addRatingForSongId:(NSString*)song{

    //添加rating
    [MusicKit.new.api.library addRating:song byType:CRatingSongs value:1 callBack:^(NSDictionary *json, NSHTTPURLResponse *response) {
        if (response.statusCode/10==20) {

            //请求Rating 的默认库播放列表 identifier,
            [MusicKit.new.api.library searchForTerm:@"Rating" byType:SLibraryPlaylists callBack:^(NSDictionary *json, NSHTTPURLResponse *response) {
                NSDictionary *track = @{@"id":song,@"type":@"songs"};
                NSArray *list = [json valueForKeyPath:@"results.library-playlists.data"];
                NSString *identifier = [list.firstObject valueForKey:@"id"];

                [MusicKit.new.api.library addTracksToLibraryPlaylists:identifier tracks:@[track,] callBack:^(NSDictionary *json, NSHTTPURLResponse *response) {
                    //
                }];
            }];
            //更新ui
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.playerView.heartIcon setOn:YES animated:YES];
            });
        }
    }];
}
-(void)addResourceToLibrary:(NSString*) identifier{
    [MusicKit.new.api.library addResourceToLibraryForIdentifiers:@[identifier,] byType:AddSongs callBack:^(NSDictionary *json, NSHTTPURLResponse *response) {
        Log(@"res =%ld",response.statusCode);
        //更新ui
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.playerView.heartIcon setOn:YES animated:YES];
        });
    }];
}

@end
