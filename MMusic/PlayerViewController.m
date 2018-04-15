//
//  PlayerViewController.m
//  MMusic
//
//  Created by Magician on 2018/3/11.
//  Copyright © 2018年 com.😈. All rights reserved.
//
#import <UIImageView+WebCache.h>
#import <VBFPopFlatButton.h>

#import "PlayerViewController.h"
#import "PlayerView.h"
#import "PlayProgressView.h"
#import "PlayControllerView.h"

#import "Artwork.h"
#import "Song.h"
#import "PersonalizedRequestFactory.h"
#import "NSObject+Tool.h"

@interface PlayerViewController ()
@property(nonatomic, strong) PlayerView *playerView;
@property(nonatomic, strong) NSTimer *timer;
@property(nonatomic, strong) UIActivityIndicatorView *indicator;
@end

static PlayerViewController *_instance;
@implementation PlayerViewController

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
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateNowPlayItemToView];
        });

        //向外传出正在播放的项目
        _nowPlayingItem(self.playerController.nowPlayingItem);
    }];

    //播放状态改变
    [center addObserverForName:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {

        //播放状态 更改, 改变按钮
        switch (weakSelf.playerController.playbackState) {
            case MPMusicPlaybackStatePlaying:
                [_playerView.playCtrView.play setCurrentButtonType:buttonPausedType];
                [self.timer fire];
                break;

            case MPMusicPlaybackStatePaused:
            case MPMusicPlaybackStateStopped:
            case MPMusicPlaybackStateInterrupted:
                [_playerView.playCtrView.play animateToType:buttonRightTriangleType];
                [weakSelf.timer invalidate];    //取消计时
                weakSelf.timer = nil;           //下次开始播放时, 重新实例计时器
                break;

            default:
                break;
        }
    }];
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
    [center removeObserver:self name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:nil];
    [self.playerController endGeneratingPlaybackNotifications];
}

/**更新当前播放的音乐信息到视图上*/
- (void) updateNowPlayItemToView{

    //歌曲封面
    NSString *imagePath = IMAGEPATH_FOR_URL(self.nowPlaySong.artwork.url);
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    if (image) {
        [self.playerView.artworkView setImage:image];
    }else{
        //图片地址
        int h = CGRectGetHeight(self.playerView.artworkView.bounds);
        int w = h;
        NSString *url = self.nowPlaySong.artwork.url;
        url = [self stringReplacingOfString:url height:h width:w];

        //网络加载指示器
        [self.playerView.artworkView addSubview:self.indicator];

        //添加 封面 图片
        [_playerView.artworkView sd_setImageWithURL:[NSURL URLWithString:url] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            [self.indicator stopAnimating];
            [self.indicator removeFromSuperview];
            self.indicator = nil;
            BOOL sucess = [[NSFileManager defaultManager] createFileAtPath:imagePath contents:UIImagePNGRepresentation(image) attributes:nil];
            if (sucess==NO) [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
        }];
    }

    //歌曲  歌手信息
    self.playerView.songNameLabel.text = self.nowPlaySong.name;
    self.playerView.artistLabel.text = self.nowPlaySong.artistName;

    //歌曲总时长
    int duration = self.nowPlaySong.durationInMillis.intValue; //(毫秒)
    int min = duration /(1000*60);
    int sec = (duration - (min*60*1000) ) /1000;
    self.playerView.progressView.durationTime.text =[NSString stringWithFormat:@"%.2d:%.2d",min,sec];

    //是否是喜爱的歌曲
}

#pragma mark layz 加载指示器
-(UIActivityIndicatorView *)indicator{
    if (!_indicator) {
        _indicator = [[UIActivityIndicatorView alloc] initWithFrame:_playerView.artworkView.bounds];
        [_indicator setHidesWhenStopped:YES];
        [_indicator setColor:[UIColor grayColor]];
        [_indicator startAnimating];
    }
    return _indicator;
}

#pragma mark layz 音乐播放控制器
-(MPMusicPlayerController *)playerController{
    if (!_playerController) {
        _playerController = [MPMusicPlayerController systemMusicPlayer];
        //[_playerController setRepeatMode:MPMusicRepeatModeDefault];     //默认循环模式

        [_playerController beginGeneratingPlaybackNotifications];       //开启消息
    }
    return _playerController;
}

#pragma mark layz 音乐播放器界面
-(PlayerView *)playerView{
    if (!_playerView) {
        _playerView = [[PlayerView alloc] initWithFrame:self.view.bounds];

        //事件绑定
        [_playerView.progressView.progressSlider addTarget:self action:@selector(sliderChange:) forControlEvents:UIControlEventValueChanged];
        [_playerView.closeButton addTarget:self action:@selector(closeViewController) forControlEvents:UIControlEventTouchDown];
        [_playerView.like addTarget:self action:@selector(changeLove:) forControlEvents:UIControlEventTouchDown];
        [_playerView.playCtrView.previous addTarget:self action:@selector(previous:) forControlEvents:UIControlEventTouchDown];
        [_playerView.playCtrView.play addTarget:self action:@selector(playOrPause:) forControlEvents:UIControlEventTouchDown];
        [_playerView.playCtrView.next addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchDown];
    }
    return _playerView;
}

/** 播放时长计时器, 更新已经播放时间和 进度*/
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
             //Log(@"current=%f, duration=%f value=%f",current,duration, value);
        }];
    }
    return _timer;
}

/**关闭 播放器视图控制器*/
- (void)closeViewController{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}
#pragma mark 播放器 按钮事件
- (void)sliderChange:(UISlider*) slider{

    NSTimeInterval duration = self.playerController.nowPlayingItem.playbackDuration; //秒
    NSTimeInterval current = duration * slider.value;
    int min = current/60;
    int sec = current - min*60;
    //Log(@"duration=%.0f  time:%.0f current=%.0f",duration,self.playerController.currentPlaybackTime,current);
    //更新已经播放时长
    [_playerView.progressView.currentTime setText:[NSString stringWithFormat:@"%.2d:%.2d",min,sec]];

    [self.playerController setCurrentPlaybackTime:current];
}

- (void)previous:(UIButton*) button{
    [self.playerController skipToPreviousItem];
}
- (void)playOrPause:(UIButton*) button{
    switch (self.playerController.playbackState) {
        case MPMusicPlaybackStatePlaying:
            [self.playerController pause];
            break;
        case MPMusicPlaybackStatePaused:
        case MPMusicPlaybackStateStopped:
            [self.playerController play];
            break;

        default:
            break;
    }
}
-(void)next:(UIButton*) button{
    [self.playerController skipToNextItem];
}

- (void)changeLove:(UIButton*) button{
    
}

@end
