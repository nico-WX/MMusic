//
//  Player.m
//  MMusic
//
//  Created by Magician on 2018/6/27.
//  Copyright © 2018年 com.😈. All rights reserved.
//


#import "Player.h"
#import "PlayerView.h"
#import "MusicVideo.h"
#import "ArtistsModel.h"
#import "DBTool.h"
#import "Artwork.h"


@interface Player ()<MPSystemMusicPlayerController>
/**播放器*/
@property(nonatomic, strong) MPMusicPlayerController *playerController;
/**播放器UI*/
@property(nonatomic, strong) PlayerView *playerView;
/**播放进度定时器*/
@property(nonatomic, strong) NSTimer *timer;
/**正在播放的歌曲*/
@property(nonatomic, strong) NSArray<Song*> *songs;
@end

static Player *_player;

@implementation Player

#pragma mark - init

+(instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_player) _player = [[super alloc] init];
    });
    return _player;
}
-(id)copyWithZone:(NSZone *)zone{
    return _player;
}

-(id)mutableCopyWithZone:(NSZone *)zone{
    return _player;
}

#if __has_feature(objc_arc)
//ARC
#else
//MRC
- (oneway void)release{
    //拦截释放
}
- (instancetype)retain{
    //拦截增加引用计数
    return _player;
}
- (NSUInteger)retainCount{
    return  MAXFLOAT;
}
#endif

#pragma mark - cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    __weak typeof(self) weakSelf = self;
    //监听通知
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    //处理播放状态
    [center addObserverForName:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {

        switch (weakSelf.playerController.playbackState) {
            case MPMusicPlaybackStatePaused:
            case MPMusicPlaybackStateStopped:
            case MPMusicPlaybackStateInterrupted:
                [weakSelf.playerView.play setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
                if (weakSelf.playState) weakSelf.playState(NAKPlaybackIndicatorViewStatePaused);
                break;

            case MPMusicPlaybackStatePlaying:
            case MPMusicPlaybackStateSeekingForward:
            case MPMusicPlaybackStateSeekingBackward:
                [weakSelf.playerView.play setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
                if (weakSelf.playState) weakSelf.playState(NAKPlaybackIndicatorViewStatePlaying);
                break;
          }
    }];
    //播放Item改变
    [center addObserverForName:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        MPMediaItem *item = weakSelf.playerController.nowPlayingItem;
        if (weakSelf.nowPlayingItem) weakSelf.nowPlayingItem(item);
        if (weakSelf.nowPlayingSong) weakSelf.nowPlayingSong([weakSelf songWithNowPlayingItem:item]);
    }];

    [self.timer fire];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    __weak typeof(self) weakSelf = self;
    self.nowPlayingSong = ^(Song *song) {
        [weakSelf updateNowPlayItemSongToView:song];
    };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [_playerController endGeneratingPlaybackNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
/**更新当前播放的音乐信息到视图上*/
- (void) updateNowPlayItemSongToView:(Song*) song{
    //主线程更新
    dispatch_async(dispatch_get_main_queue(), ^{

        /**
         1.判断当前有没有加载Song 对象, 如果没有, 页面信息从系统获取

         2.0 : 如果没有,从系统获取页面信息
         2.1 : 从系统获取时, 需要识别是否为Apple版权的音乐,还是第三方添加的,Apple版权音乐直接通过ID获取Song 对象,更新信息
         2.2 : 第三方音乐直接获取数据,更新信息
         2.3 : (未完成: 第三方音乐, 通过音乐名称,和艺人, 在Apple 目录中搜索, 返回Song 对象)
         */

        NSString *title;
        NSString *artist;
        NSString *durationString;

        if (song) {
            [self.playerView.heartIcon setEnabled:YES];
            title = song.name;
            artist= song.artistName;
            //时长
            int duration = song.durationInMillis.intValue / 1000;
            int min = duration/60;
            int sec = duration%60;
            durationString =[NSString stringWithFormat:@"%02d:%02d",min,sec];

            //封面
            [self showImageToView:self.playerView.artworkView withImageURL:song.artwork.url cacheToMemory:YES];

            //红心开关 状态查询,设置
            [self heartFromSongIdentifier:[song.playParams objectForKey:@"id"]];

        }else{
            //当前没有从app 中加载song,
            //判断系统播放器有没有在播放或者加载了音乐
            if (self.playerController.nowPlayingItem){

                //有Identifier 属于AppleMusic版权库音乐 请求Song对象
                NSString *identifier = self.playerController.nowPlayingItem.playbackStoreID;
                if ((identifier) && (![identifier isEqualToString:@"0"])) {
                    [self.playerView.heartIcon setEnabled:YES];
                    [self songFromIdentifier:self.playerController.nowPlayingItem.playbackStoreID];
                }else{
                    //第三方音乐
                    [self.playerView.heartIcon setOn:NO animated:YES];  //开关ON
                    [self.playerView.heartIcon setEnabled:NO];          //关闭开关交互, 不能添加喜欢
                    [self showHUDToMainWindowFromText:@"该音乐不是AppleMusic版权库内容"];

                    MPMediaItem *item = self.playerController.nowPlayingItem;
                    title = item.title;
                    artist = item.artist;
                    int duration = item.playbackDuration;
                    durationString = [NSString stringWithFormat:@"%02d:%02d",duration/60,duration%60];

                    //封面
                    CGSize size = self.playerView.artworkView.bounds.size;
                    UIImage *image = [item.artwork imageWithSize:size];
                    [self.playerView.artworkView setImage:image];
                }
            }else{
                //没有在播放
                [self showHUDToMainWindowFromText:@"系统播放器没有加载音乐"];
                [self.playerView.heartIcon setEnabled:NO];
            }
        }

        //页面信息
        self.playerView.songNameLabel.text = title;
        self.playerView.artistLabel.text = artist;
        if (durationString) {
            self.playerView.durationTime.text = durationString;
        }
        //收集艺人信息, 填充艺人列表数据
        [self addArtistsToDataBaseFromSong:song];
    });
}


#pragma mark - helper
/**查找当前队列中匹配的song*/
-(nullable Song*)songWithNowPlayingItem:(MPMediaItem*)item{
    for (Song *song in self.songs ) {
        if ([song isEqualToMediaItem:item]) {
            return song;
        }
    }
    return nil;
}
/**存储艺人信息 , 添加到数据库, 创建艺人列表*/
-(void)addArtistsToDataBaseFromSong:(Song*) song{

    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage *image = self.playerView.artworkView.image;
        if (!image) image = [self imageFromURL:song.artwork.url withImageSize:self.playerView.artworkView.frame.size];
        if (song.artistName) {
            //获取艺人 ID  写入数据库, 用来创建艺人列表
            [MusicKit.new.api searchForTerm:song.artistName callBack:^(NSDictionary *json, NSHTTPURLResponse *response) {
                json = [[json valueForKeyPath:@"results.artists.data"] lastObject];

                ArtistsModel *artist = [ArtistsModel new];
                artist.name = song.artistName;
                artist.image = image;
                artist.identifier = [json valueForKey:@"id"];

                [DBTool addArtists:artist];
            }];
        }
    });
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

//通过音乐 id 获取song 对象;
-(void)songFromIdentifier:(NSString*) identifier{
    [MusicKit.new.api resources:@[identifier,] byType:CatalogSongs callBack:^(NSDictionary *json, NSHTTPURLResponse *response) {
        if (json) {
            [json enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                [(NSArray*)obj enumerateObjectsUsingBlock:^(id  _Nonnull songResource, NSUInteger idx, BOOL * _Nonnull stop) {
                    Song *song = [Song instanceWithDict:[songResource objectForKey:@"attributes"]];
                    if (self.songs.count  == 0) self.songs = @[song,];
                }];
            }];
        }
    }];
}

#pragma mark - 更新UI信息


#pragma mark - instanc method
-(void)playSongs:(NSArray<Song *> *)songs startIndex:(NSUInteger)startIndex{
    self.songs = songs;

    NSMutableArray<MPMusicPlayerPlayParameters*> *array = [NSMutableArray array];
    for (Song *song in songs) {
        MPMusicPlayerPlayParameters *parameter = [[MPMusicPlayerPlayParameters alloc] initWithDictionary:song.playParams];
        [array addObject:parameter];
    }
    MPMusicPlayerPlayParametersQueueDescriptor *queue = [[MPMusicPlayerPlayParametersQueueDescriptor alloc] initWithPlayParametersQueue:array];
    [queue setStartItemPlayParameters:[array objectAtIndex:startIndex]];
    [self.playerController setQueueWithDescriptor:queue];
    [self.playerController play];
}
-(void)insertSongAtNextItem:(Song *)song{
    MPMusicPlayerPlayParameters *parameter = [[MPMusicPlayerPlayParameters alloc] initWithDictionary:song.playParams];
    MPMusicPlayerPlayParametersQueueDescriptor *queue = [[MPMusicPlayerPlayParametersQueueDescriptor alloc] initWithPlayParametersQueue:@[parameter,]];
    [self.playerController prependQueueDescriptor:queue];

    //数据添加到指定位置
    NSMutableArray<Song*> *array = [NSMutableArray arrayWithArray:self.songs];
    NSUInteger index = self.playerController.indexOfNowPlayingItem;
    [array insertObject:song atIndex:++index]; //当前播放下标后面
    self.songs = array;
}
-(void)insertSongAtEndItem:(Song *)song{
    MPMusicPlayerPlayParameters *parameter = [[MPMusicPlayerPlayParameters alloc] initWithDictionary:song.playParams];
    MPMusicPlayerPlayParametersQueueDescriptor *queue = [[MPMusicPlayerPlayParametersQueueDescriptor alloc] initWithPlayParametersQueue:@[parameter,]];
    [self.playerController appendQueueDescriptor:queue];

    //插入添加数据
    self.songs = [self.songs arrayByAddingObject:song];
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

#pragma mark - getter
- (MPMusicPlayerController *)playerController{
    if (!_playerController) {
        _playerController = [MPMusicPlayerController systemMusicPlayer];
        [_playerController beginGeneratingPlaybackNotifications];
    }
    return _playerController;
}
-(PlayerView *)playerView{
    if (!_playerView) {
        _playerView = [[PlayerView alloc] initWithFrame:self.view.bounds];
        //事件绑定
        [_playerView.progressView   addTarget:self action:@selector(sliderChange:) forControlEvents:UIControlEventValueChanged];
        [_playerView.previous       addTarget:self action:@selector(previous:) forControlEvents:UIControlEventTouchUpInside];
        [_playerView.play           addTarget:self action:@selector(playOrPause:) forControlEvents:UIControlEventTouchUpInside];
        [_playerView.next           addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchUpInside];
        [_playerView.heartIcon      addTarget:self action:@selector(changeLove:) forControlEvents:UIControlEventTouchUpInside];

        //下滑隐藏控制器 手势
        UISwipeGestureRecognizer *gesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissViewController)];
        [gesture setDirection:UISwipeGestureRecognizerDirectionDown];
        [_playerView addGestureRecognizer:gesture];
    }
    return _playerView;
}
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

#pragma mark - Button Action

//手势 action
-(void)dismissViewController{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//进度条拖拽事件
- (void)sliderChange:(UISlider*) slider{
    NSTimeInterval duration = self.playerController.nowPlayingItem.playbackDuration; //秒
    NSTimeInterval current = duration * slider.value;
    [self.playerController setCurrentPlaybackTime:current];

//    int min = (int)current/60;
//    int sec = (int)current%60;
//    self.playerView.currentTime.text = [NSString stringWithFormat:@"%.2d:%.2d",min,sec];
}

//上一首
- (void)previous:(UIButton*) button{
    [self.playerController skipToPreviousItem];
    [self animationButton:button];
}

//播放或暂停
- (void)playOrPause:(UIButton*) button{
    switch (self.playerController.playbackState) {
        case MPMusicPlaybackStatePlaying:
            [self.playerController pause];
            [self animationButton:button];
            [button setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
            break;

        case MPMusicPlaybackStatePaused:
        case MPMusicPlaybackStateStopped:
        case MPMusicPlaybackStateInterrupted:
            //[self.timer fire];
            [self.playerController play];
            [self animationButton:button];
            [button setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
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
            [self addRatingForSongId:identifier];
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
                    Log(@"add track code =%ld",response.statusCode);
                }];

                //                [MusicKit.new.api.library addTracksToLibraryPlaylists:identifier playload:track callBack:^(NSDictionary *json, NSHTTPURLResponse *response) {
                //
                //                }];
            }];

            //更新ui
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.playerView.heartIcon setOn:YES animated:YES];
            });
        }
    }];
}

@end
