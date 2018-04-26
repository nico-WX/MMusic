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

#pragma mark - cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.view = self.playerView;

    //监听消息
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    __weak typeof(self) weakSelf = self;
    // 播放项目改变
    [center addObserverForName:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        //更新本地现在播放项目  及 播放项目的index  在设值方法中触发更新UI方法
        weakSelf.nowPlaySong = [weakSelf.songs objectAtIndex:weakSelf.playerController.indexOfNowPlayingItem];
        [weakSelf updateNowPlayItemToView];

        //块是否为空, 不为空,向外传递正在播放的项目
        if (_nowPlayingItem) {
            _nowPlayingItem(weakSelf.playerController.nowPlayingItem);
        }
    }];

    //开始获取当前播放时间
    [self.timer fire];
}

- (void)viewDidAppear:(BOOL)animated{
    // 更新正在播放的信息
    [self updateNowPlayItemToView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:nil];
    [self.playerController endGeneratingPlaybackNotifications];
}

#pragma mark - 显示视图控制器
-(void)showFromViewController:(UIViewController *)vc withSongs:(NSArray<Song *> *)songs startItem:(Song *)startSong{
    self.songs = songs;
    self.nowPlaySong = startSong;
    [vc presentViewController:self animated:YES completion:nil];
}

#pragma mark - 更新UI信息
/**更新当前播放的音乐信息到视图上*/
- (void) updateNowPlayItemToView{
    Artwork *artwork = self.nowPlaySong.artwork;

    UIColor *mainColor = [UIColor colorWithHexString:artwork.bgColor alpha:1];
    self.playerView.closeButton.tintColor = [UIColor oppositeColorOf:mainColor];    //按钮补色
    [self.playerView.closeButton animateToType:buttonCloseType];

    //歌曲封面
    [self showImageToView:self.playerView.artworkView withImageURL:artwork.url cacheToMemory:YES];

    //歌曲  歌手信息
    self.playerView.songNameLabel.text = self.nowPlaySong.name;
    self.playerView.artistLabel.text = self.nowPlaySong.artistName;

    //歌曲总时长
    int duration = self.nowPlaySong.durationInMillis.intValue; //(毫秒)
    int min = duration /(1000*60);
    int sec = (duration - (min*60*1000) ) /1000;
    self.playerView.progressView.durationTime.text =[NSString stringWithFormat:@"%.2d:%.2d",min,sec];

    //是否是喜爱的歌曲
    NSString *songID = [self.nowPlaySong.playParams objectForKey:@"id"];
    NSURLRequest *request = [[PersonalizedRequestFactory new] createManageRatingsRequestWithType:GetSongRatingsType resourceIds:@[songID,]];

    [self dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error && data ) {
            NSHTTPURLResponse *res = (NSHTTPURLResponse*) response;
            NSDictionary *json = [self serializationDataWithResponse:response data:data error:nil];
            if (json && res.statusCode==200) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.playerView.like setImage:[UIImage imageNamed:@"love-red"] forState:UIControlStateNormal];
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.playerView.like setImage:[UIImage imageNamed:@"love-gray"] forState:UIControlStateNormal];
                });
            }
        }
    }];
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
        [_playerView.progressView.progressSlider addTarget:self action:@selector(sliderChange:) forControlEvents:UIControlEventValueChanged];
        [_playerView.closeButton addTarget:self action:@selector(closeViewController:) forControlEvents:UIControlEventTouchUpInside];
        [_playerView.like addTarget:self action:@selector(changeLove:) forControlEvents:UIControlEventTouchUpInside];
        [_playerView.playCtrView.previous addTarget:self action:@selector(previous:) forControlEvents:UIControlEventTouchUpInside];
        [_playerView.playCtrView.play addTarget:self action:@selector(playOrPause:) forControlEvents:UIControlEventTouchUpInside];
        [_playerView.playCtrView.next addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchUpInside];
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
            int sec = (int)(current-min*60);
            weakSelf.playerView.progressView.currentTime.text = [NSString stringWithFormat:@"%.2d:%.2d",min,sec];

            //更新进度条
            NSTimeInterval duration = weakSelf.playerController.nowPlayingItem.playbackDuration; //秒
            CGFloat value = (current/duration);
            [weakSelf.playerView.progressView.progressSlider setValue:value animated:YES];

            //Log(@"current =%lf",self.playerController.currentPlaybackTime);
        }];
    }
    return _timer;
}

#pragma mark - Button Action
/**关闭 播放器视图控制器*/
- (void)closeViewController:(VBFPopFlatButton*) button{
    [button animateToType:buttonDownBasicType];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
        [button animateToType:buttonUpBasicType];
    });
}

//播放控制 Action
- (void)sliderChange:(UISlider*) slider{
    NSTimeInterval duration = self.playerController.nowPlayingItem.playbackDuration; //秒
    NSTimeInterval current = duration * slider.value;
    [self.playerController setCurrentPlaybackTime:current];
}

- (void)previous:(VBFPopFlatButton*) button{
    [self.playerController skipToPreviousItem];
    //动画
    [button animateToType:buttonBackType];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [button animateToType:buttonRewindType];
    });
}
- (void)playOrPause:(VBFPopFlatButton*) button{
    switch (self.playerController.playbackState) {
        case MPMusicPlaybackStatePlaying:
            [self.playerController pause];
            [self.timer invalidate];    //无效, 移除运行循环
            self.timer = nil;           //下一启动新的
            [button setCurrentButtonType:buttonRightTriangleType];
            break;
        case MPMusicPlaybackStatePaused:
        case MPMusicPlaybackStateStopped:
            [self.timer fire];
            [self.playerController play];
            [button setCurrentButtonType:buttonPausedType];
            break;

        default:
            break;
    }
}
-(void)next:(VBFPopFlatButton*) button{
    [self.playerController skipToNextItem];
    //动画
    [button animateToType:buttonForwardType];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [button animateToType:buttonFastForwardType];
    });
}
/**点击喜爱按钮*/
- (void)changeLove:(UIButton*) button{
    PersonalizedRequestFactory *factort = [PersonalizedRequestFactory new];
    NSString *songID = [self.nowPlaySong.playParams objectForKey:@"id"];

    // 查询当前rating状态  --> 操作
    NSURLRequest *getRating = [factort createManageRatingsRequestWithType:GetSongRatingsType resourceIds:@[songID,]];
    [self dataTaskWithRequest:getRating completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error && data ) {
            NSHTTPURLResponse *res = (NSHTTPURLResponse*) response;
            NSDictionary *json = [self serializationDataWithResponse:response data:data error:nil];
            //喜欢
            if (json && res.statusCode==200) {
                //取消喜欢
                //DELETE
                NSURLRequest *request = [factort createManageRatingsRequestWithType:DeleteSongRatingsType resourceIds:@[songID,]];
                [self dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    NSHTTPURLResponse *res = (NSHTTPURLResponse*) response;
                    if (!error && res.statusCode/10 == 20) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.playerView.like setImage:[UIImage imageNamed:@"love-gray"] forState:UIControlStateNormal];
                        });
                    }
                }];
            //不喜欢
            }else{
                //添加喜欢
                //PUT
                NSString *songID = [self.nowPlaySong.playParams objectForKey:@"id"];
                NSURLRequest *request = [factort createManageRatingsRequestWithType:AddSongRatingsType resourceIds:@[songID,]];
                [self dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    NSHTTPURLResponse *res = (NSHTTPURLResponse*) response;
                    if (!error && res.statusCode/10==20) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.playerView.like setImage:[UIImage imageNamed:@"love-red"] forState:UIControlStateNormal];
                        });
                    }
                }];
            }
        }
    }];

}


@end
