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

@interface PlayerViewController ()
/**播放器UI*/
@property(nonatomic, strong) PlayerView *playerView;
/**定时获取播放时间,更新UI*/
@property(nonatomic, strong) NSTimer *timer;
/**歌曲列表*/
@property(nonatomic, strong) NSArray<Song*> *songs;
@end


static PlayerViewController *_instance;
@implementation PlayerViewController

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
        if (!_instance) {
            _instance = [super allocWithZone:zone];
        }
    });
    return _instance;
}
-(id)copyWithZone:(NSZone *)zone{
    return _instance;
}
-(id)mutableCopyWithZone:(NSZone *)zone{
    return _instance;
}
- (instancetype)init{
    if (self =[super init]) {
        [self.view setBackgroundColor:UIColor.whiteColor];
    }
    return self;
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
        if (_nowPlayingItem) _nowPlayingItem(weakSelf.playerController.nowPlayingItem);
    }];

    //开始获取当前播放时间
    [self.timer fire];
}

- (void)viewDidAppear:(BOOL)animated{
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
            //红心
            [self heartFromSongIdentifier:[song.playParams objectForKey:@"id"]];

        }else{
            //有Identifier 是AppleMusic版权库音乐 请求Song对象
            if (![self.playerController.nowPlayingItem.playbackStoreID isEqualToString:@"0"]) {
                [self songFromIdentifier:self.playerController.nowPlayingItem.playbackStoreID];
            }else{
                //第三方音乐
                [self.playerView.heartIcon setEnabled:NO];  //关闭开关
                [self showHUDToMainWindowFromText:@"该音乐非AppleMusic版权库内容"];
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

        }

        self.playerView.songNameLabel.text = title;
        self.playerView.artistLabel.text = artist;
        self.playerView.progressView.durationTime.text = durationString;
    });

}

//获取歌曲rating
-(void)heartFromSongIdentifier:(NSString*) identifier{
    if (identifier) {
        NSURLRequest *request = [[PersonalizedRequestFactory new] createManageRatingsRequestWithType:GetSongRatingsType resourceIds:@[identifier,]];
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
    NSURLRequest *request = [[RequestFactory new] createRequestWithType:RequestSongType resourceIds:@[identifier,]];
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
        [_playerView.progressView.progressSlider    addTarget:self action:@selector(sliderChange:) forControlEvents:UIControlEventValueChanged];
        [_playerView.playCtrView.previous           addTarget:self action:@selector(previous:) forControlEvents:UIControlEventTouchUpInside];
        [_playerView.playCtrView.play               addTarget:self action:@selector(playOrPause:) forControlEvents:UIControlEventTouchUpInside];
        [_playerView.playCtrView.next               addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchUpInside];
        [_playerView.heartIcon                      addTarget:self action:@selector(changeLove:) forControlEvents:UIControlEventTouchUpInside];

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
            NSTimeInterval current = _playerController.currentPlaybackTime;//秒
            int min = (int)current/60;
            int sec = (int)current%60;
            weakSelf.playerView.progressView.currentTime.text = [NSString stringWithFormat:@"%.2d:%.2d",min,sec];

            //更新进度条
            NSTimeInterval duration = weakSelf.playerController.nowPlayingItem.playbackDuration; //秒
            CGFloat value = (current/duration);
            [weakSelf.playerView.progressView.progressSlider setValue:value animated:YES];
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

    NSString *songID = [self.nowPlaySong.playParams objectForKey:@"id"];
    Log(@"songid =====%@",songID);
    //判断歌曲类型
    if (songID) {
        // 查询当前rating状态(不是基于当前按钮状态)  --> 操作
        PersonalizedRequestFactory *factort = [PersonalizedRequestFactory new];
        NSURLRequest *getRating = [factort createManageRatingsRequestWithType:GetSongRatingsType resourceIds:@[songID,]];
        [self dataTaskWithRequest:getRating completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (!error && data ) {
                NSHTTPURLResponse *res = (NSHTTPURLResponse*) response;
                NSDictionary *json = [self serializationDataWithResponse:response data:data error:nil];

                if (json && res.statusCode==200) {
                    //当前为喜欢状态
                    //取消喜欢 <DELETE>
                    NSURLRequest *request = [factort createManageRatingsRequestWithType:DeleteSongRatingsType resourceIds:@[songID,]];
                    [self dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                        NSHTTPURLResponse *res = (NSHTTPURLResponse*) response;
                        if (!error && res.statusCode/10 == 20) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [heart setOn:NO animated:YES];
                            });
                        }
                    }];

                }else{
                    //当前没有添加为喜欢
                    //添加喜欢 <PUT>
                    NSString *songID = [self.nowPlaySong.playParams objectForKey:@"id"];
                    NSURLRequest *request = [factort createManageRatingsRequestWithType:AddSongRatingsType resourceIds:@[songID,]];
                    [self dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                        NSHTTPURLResponse *res = (NSHTTPURLResponse*) response;
                        if (!error && res.statusCode/10==20) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [heart setOn:YES animated:YES];
                            });
                        }
                    }];
                }
            }
        }];
    }else{
        [self showHUDToMainWindowFromText:@"非AppleMusic版权音乐,无法添加喜欢"];
        //开关ON
        [heart setOn:NO animated:YES];
    }

}


@end
