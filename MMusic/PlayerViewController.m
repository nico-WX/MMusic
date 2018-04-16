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
/**定时获取播放时间,更新UI*/
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
    NSString *songID = [self.nowPlaySong.playParams objectForKey:@"id"];
    NSURLRequest *request = [[PersonalizedRequestFactory personalizedRequestFactory] createManageRatingsRequestWithType:GetSongRatingsType resourceIds:@[songID,]];

    [self dataTaskWithdRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
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

            //Log(@"current =%lf",self.playerController.currentPlaybackTime);
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
    [self.playerController setCurrentPlaybackTime:current];
}

- (void)previous:(UIButton*) button{
    [self.playerController skipToPreviousItem];
}
- (void)playOrPause:(VBFPopFlatButton*) button{
    switch (self.playerController.playbackState) {
        case MPMusicPlaybackStatePlaying:
            [self.playerController pause];
            [button setCurrentButtonType:buttonRightTriangleType];
            break;
        case MPMusicPlaybackStatePaused:
        case MPMusicPlaybackStateStopped:
            [self.playerController play];
            [button setCurrentButtonType:buttonPausedType];
            break;

        default:
            break;
    }
}
-(void)next:(UIButton*) button{
    [self.playerController skipToNextItem];
}
/**点击喜爱按钮*/
- (void)changeLove:(UIButton*) button{
    PersonalizedRequestFactory *factort = [PersonalizedRequestFactory personalizedRequestFactory];
    NSString *songID = [self.nowPlaySong.playParams objectForKey:@"id"];

    NSURLRequest *getRating = [factort createManageRatingsRequestWithType:GetSongRatingsType resourceIds:@[songID,]];
    [self dataTaskWithdRequest:getRating completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error && data ) {
            NSHTTPURLResponse *res = (NSHTTPURLResponse*) response;
            NSDictionary *json = [self serializationDataWithResponse:response data:data error:nil];
            //喜欢
            if (json && res.statusCode==200) {
                //取消喜欢
                //DELETE
                NSURLRequest *request = [factort createManageRatingsRequestWithType:DeleteSongRatingsType resourceIds:@[songID,]];
                [self dataTaskWithdRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    NSHTTPURLResponse *res = (NSHTTPURLResponse*) response;
                    Log(@"delete =%ld",res.statusCode);
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
                [self dataTaskWithdRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    NSHTTPURLResponse *res = (NSHTTPURLResponse*) response;
                    Log(@"PUT add =%ld",res.statusCode);
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
