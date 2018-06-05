//
//  PlayerViewController.m
//  MMusic
//
//  Created by Magician on 2018/3/11.
//  Copyright © 2018年 com.😈. All rights reserved.
//
#import <MBProgressHUD.h>
#import <UIImageView+WebCache.h>
#import <VBFPopFlatButton.h>

#import "PlayerViewController.h"
#import "PlayerView.h"
#import "PlayProgressView.h"
#import "PlayControllerView.h"

#import "NSObject+Tool.h"
#import "Artwork.h"
#import "Song.h"
#import "PersonalizedRequestFactory.h"
#import "RequestFactory.h"
#import "NSObject+Tool.h"


#import "DBTool.h"
#import "TracksModel.h"
#import "ArtistsModel.h"


@interface PlayerViewController ()
/**个人 请求*/
@property(nonatomic, strong) PersonalizedRequestFactory *factory;
/**播放器UI*/
@property(nonatomic, strong) PlayerView *playerView;

/**定时获取播放时间,更新UI*/
@property(nonatomic, strong) NSTimer *timer;

/**歌曲列表*/
@property(nonatomic, strong) NSArray<Song*> *songs;

@property(nonatomic, strong)MPMusicPlayerPlayParametersQueueDescriptor *parametersQueue;
@end


static PlayerViewController *_instance;


@implementation PlayerViewController

@synthesize playbackIndicatorView = _playbackIndicatorView;

#pragma mark - 初始化 / 单例
+ (instancetype)sharePlayerViewController{
    if (!_instance) {
        _instance = [[self alloc] init];
    }
    return _instance;
}
+(instancetype)allocWithZone:(struct _NSZone *)zone{
    //防止同时访问
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_instance) _instance = [super allocWithZone:zone];
    });
    return _instance;
}
-(instancetype)initWithTrackArray:(NSArray<Song *> *)trackArray startIndex:(NSUInteger)startIndex{
    if (self = [super init]) {
        _songs = trackArray;
        _nowPlaySong = [trackArray objectAtIndex:startIndex];
        _parametersQueue = [self playParametersQueueFromSongs:trackArray startPlayIndex:startIndex];
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

    //添加视图
    self.view = self.playerView;

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    __weak typeof(self) weakSelf = self;
    // 监听播放项目改变
    [center addObserverForName:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        //更新本地现在播放项目 在设值方法中触发更新UI方法
        //这里不判断self.songs  ,如果没有就赋值空
        weakSelf.nowPlaySong = [weakSelf.songs objectAtIndex:weakSelf.playerController.indexOfNowPlayingItem];

        //向外传递正在播放的项目
        if (weakSelf.nowPlayingItem) weakSelf.nowPlayingItem(weakSelf.playerController.nowPlayingItem);
    }];

    //播放状态;
    [center addObserverForName:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {

        MPMusicPlayerController *ctr = note.object;
        switch (ctr.playbackState) {
            case MPMusicPlaybackStatePaused:
            case MPMusicPlaybackStateStopped:
            case MPMusicPlaybackStateInterrupted:
                [weakSelf.playbackIndicatorView setState:NAKPlaybackIndicatorViewStatePaused];
                break;

            case MPMusicPlaybackStatePlaying:
            case MPMusicPlaybackStateSeekingForward:
            case MPMusicPlaybackStateSeekingBackward:
                [weakSelf.playbackIndicatorView setState:NAKPlaybackIndicatorViewStatePlaying];
                break;
        }
    }];

    //开始获取当前播放时间
    [self.timer fire];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    //更新播放按钮状态
    switch (self.playerController.playbackState) {
        case MPMusicPlaybackStatePaused:
        case MPMusicPlaybackStateStopped:
        case MPMusicPlaybackStateInterrupted:{
            [self.playerView.play animateToType:buttonRightTriangleType];
        }

            break;
        case MPMusicPlaybackStatePlaying:{
            [self.playerView.play animateToType:buttonPausedType];
        }
            break;
        default:
            break;
    }

    //更新UI歌曲信息
   [self updateNowPlayItemToView];
}

- (void)dealloc{
    [self.playerController endGeneratingPlaybackNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 更新UI信息
/**更新当前播放的音乐信息到视图上*/
- (void) updateNowPlayItemToView{
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

        if (self.nowPlaySong) {
            [self.playerView.heartIcon setEnabled:YES];
            Song *song = self.nowPlaySong;
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

            //判断当前播放时有没有在播放(加载了音乐)
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
                [self showHUDToMainWindowFromText:@"当前没有在播放!"];
                [self.playerView.heartIcon setEnabled:NO];
            }
        }

        //页面信息
        self.playerView.songNameLabel.text = title;
        self.playerView.artistLabel.text = artist;

        if (durationString) {
            self.playerView.durationTime.text = durationString;
        }
    });
}

#pragma mark - Helper

/**获取歌曲rating 状态, 并设置 开关状态*/
-(void)heartFromSongIdentifier:(NSString*) identifier{
    if (identifier) {
        NSURLRequest *request = [[PersonalizedRequestFactory new] managerCatalogAndLibraryRatingsWithOperatin:RatingsGetOperation
                                                                                                resourcesType:ResourcesPersonalSongType
                                                                                                       andIds:@[identifier,]];

        [self dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (!error && data ) {
                NSHTTPURLResponse *res = (NSHTTPURLResponse*) response;
                NSDictionary *json = [self serializationDataWithResponse:response data:data error:nil];
                BOOL love = (json && res.statusCode==200) ? YES : NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.playerView.heartIcon setOn:love animated:YES];
                });
            }
        }];
    }
}

//通过音乐 id 获取song 对象;
-(void)songFromIdentifier:(NSString*) identifier{
    NSURLRequest *request = [[RequestFactory new] fetchResourceFromType:ResourceSongsType andIds:@[identifier,]];
    //createRequestWithType:RequestSongType resourceIds:@[identifier,]];
    [self dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *json = [self serializationDataWithResponse:response data:data error:error];
        if (json) {
            [json enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                [(NSArray*)obj enumerateObjectsUsingBlock:^(id  _Nonnull songResource, NSUInteger idx, BOOL * _Nonnull stop) {
                    Song *song = [Song instanceWithDict:[songResource objectForKey:@"attributes"]];
                    self.nowPlaySong = song;
                }];
            }];
        }
    }];
}

// 显示视图控制器
-(void)showFromViewController:(UIViewController *)vc withSongs:(NSArray<Song *> *)songs startItem:(Song *)startSong{
    self.songs = songs;
    self.nowPlaySong = startSong;
    [vc presentViewController:self animated:YES completion:nil];
}

#pragma mark - getter

-(PersonalizedRequestFactory *)factory{
    if (!_factory) {
        _factory = [PersonalizedRequestFactory new];
    }
    return _factory;
}

-(MPMusicPlayerController *)playerController{
    if (!_playerController) {
        _playerController = [MPMusicPlayerController systemMusicPlayer];
        [_playerController beginGeneratingPlaybackNotifications];       //开启消息
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
        UISwipeGestureRecognizer *gesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(closeViewController)];
        [gesture setDirection:UISwipeGestureRecognizerDirectionDown];
        [_playerView addGestureRecognizer:gesture];

        //pan
        //UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(closeViewController)];
        
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
-(void)setNowPlaySong:(Song *)nowPlaySong{
    
    _nowPlaySong = nowPlaySong;
    [self updateNowPlayItemToView];
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
}

//上一首
- (void)previous:(VBFPopFlatButton*) button{
    [self.playerController skipToPreviousItem];
    //动画
    [button animateToType:buttonBackType];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [button animateToType:buttonRewindType];
    });
}

//播放或暂停
- (void)playOrPause:(VBFPopFlatButton*) button{
    switch (self.playerController.playbackState) {
        case MPMusicPlaybackStatePlaying:
            [self.playerController pause];
            [button setCurrentButtonType:buttonRightTriangleType];
            break;

        case MPMusicPlaybackStatePaused:
        case MPMusicPlaybackStateStopped:
        case MPMusicPlaybackStateInterrupted:
            [self.timer fire];
            [self.playerController play];
            [button setCurrentButtonType:buttonPausedType];
            break;

        default:
            break;
    }
}

//下一首
-(void)next:(VBFPopFlatButton*) button{
    [self.playerController skipToNextItem];
    //动画
    [button animateToType:buttonForwardType];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [button animateToType:buttonFastForwardType];
    });
}

//红心按钮 添加喜欢或者取消喜欢
- (void)changeLove:(LOTAnimatedSwitch*) heart{

    NSString *identifier = self.playerController.nowPlayingItem.playbackStoreID; //[self.nowPlaySong.playParams objectForKey:@"id"];
    // 查询当前rating状态(不是基于当前按钮状态)  --> 操作

    NSURLRequest *getRating = [self.factory managerCatalogAndLibraryRatingsWithOperatin:RatingsGetOperation
                                                                     resourcesType:ResourcesPersonalSongType
                                                                            andIds:@[identifier,]];

    [self dataTaskWithRequest:getRating completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        NSHTTPURLResponse *res = (NSHTTPURLResponse*) response;
        //状态码200 为有Rating   非200为没Rating
        NSDictionary *json = [self serializationDataWithResponse:response data:data error:nil];
        if (json && res.statusCode==200) {
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
    NSURLRequest *request = [self.factory managerCatalogAndLibraryRatingsWithOperatin:RatingsDeleteOperation
                                                                   resourcesType:ResourcesPersonalSongType
                                                                          andIds:@[identifier,]];

    [self dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *res = (NSHTTPURLResponse*) response;
        if (!error && res.statusCode/10 == 20) {
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
-(void) addRatingForSongId:(NSString*)songID{

    //添加rating
    NSURLRequest *request = [self.factory managerCatalogAndLibraryRatingsWithOperatin:RatingsAddOperation
                                                                        resourcesType:ResourcesPersonalSongType
                                                                               andIds:@[songID,]];

    [self dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *res = (NSHTTPURLResponse*) response;
        if (!error && res.statusCode/10==20) {
            //将track  添加到默认Rating 列表中
            [self.factory fetchIdentiferForSearchLibraryType:SearchLibraryPlaylistsType name:@"Rating" usingBlock:^(NSString *identifier) {
                NSDictionary *track = @{@"id":songID,@"type":@"songs"};
                [self.factory addTrackToPlaylists:identifier tracks:@[track,]];
            }];

            //添加到数据库存储
            for (Song *song in self.songs) {
                if ([[song.playParams valueForKey:@"id"] isEqualToString:songID]) {
                    TracksModel *tracks = [[TracksModel alloc] init];
                    tracks.name         = song.name;
                    tracks.identifier   = [song.playParams valueForKey:@"id"];
                    [DBTool insertData:tracks];
                }
            }

            //更新ui
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.playerView.heartIcon setOn:YES animated:YES];

            });
        }
    }];
}

-(NAKPlaybackIndicatorView *)playbackIndicatorView{
    if (!_playbackIndicatorView) {
        NAKPlaybackIndicatorViewStyle *style = [NAKPlaybackIndicatorViewStyle iOS10Style];
        _playbackIndicatorView = [[NAKPlaybackIndicatorView alloc] initWithStyle:style];
        [_playbackIndicatorView setUserInteractionEnabled:NO];
        //[_playbackIndicatorView setTintColor:MainColor];

        switch (self.playerController.playbackState){
            case MPMusicPlaybackStatePaused:
            case MPMusicPlaybackStateStopped:
            case MPMusicPlaybackStateInterrupted:
                [_playbackIndicatorView setState:NAKPlaybackIndicatorViewStatePaused];
                break;

            case MPMusicPlaybackStatePlaying:
            case MPMusicPlaybackStateSeekingForward:
            case MPMusicPlaybackStateSeekingBackward:
                [_playbackIndicatorView setState:NAKPlaybackIndicatorViewStatePlaying];
                break;
        }
    }
    return _playbackIndicatorView;
}


@end
