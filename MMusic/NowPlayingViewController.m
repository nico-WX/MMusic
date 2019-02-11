//
//  RedViewController.m
//  ScrollPage
//
//  Created by 🐙怪兽 on 2018/11/8.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import <Masonry.h>

#import "NowPlayingViewController.h"
#import "MPMusicPlayerController+ResourcePlaying.h"
#import "MPMediaItemArtwork+Exchange.h"

#import "PlayProgressView.h"
#import "MMHeartSwitch.h"
#import "MMPlayerView.h"
#import "MMPlayerButton.h"

#import "CoreDataStack.h"
#import "SongManageObject.h"

#import "DataStoreKit.h"
#import "Artwork.h"
#import "Song.h"

@interface NowPlayingViewController ()
@property(nonatomic, strong) MMPlayerView *playerView;
@end

static NowPlayingViewController *_instance;
@implementation NowPlayingViewController

#pragma mark - init

+ (instancetype)sharePlayerViewController {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_instance){
            _instance = [super allocWithZone:zone];
        }
    });
    return _instance;
}


# pragma mark - lift cycle

- (void)viewDidLoad{
    [super viewDidLoad];

    [self.view addSubview:self.playerView];

    //播放器通知
    [[NSNotificationCenter defaultCenter] addObserverForName:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self updateButtonStyle];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self updateUI];
        NSLog(@"now id =%@",MainPlayer.nowPlayingItem.playbackStoreID);
    }];

    //按钮事件
    [self.playerView.previous handleControlEvent:UIControlEventTouchUpInside withBlock:^{
        [self animationButton:self.playerView.previous];
        [MainPlayer skipToPreviousItem];
    }];
    [self.playerView.next handleControlEvent:UIControlEventTouchUpInside withBlock:^{
        [self animationButton:self.playerView.next];
        [MainPlayer skipToNextItem];
    }];
    [self.playerView.play handleControlEvent:UIControlEventTouchUpInside withBlock:^{
        [self animationButton:self.playerView.play];
        switch (MainPlayer.playbackState) {
            case MPMusicPlaybackStatePaused:
            case MPMusicPlaybackStateStopped:
            case MPMusicPlaybackStateInterrupted:
                [MainPlayer play];
                break;
            case MPMusicPlaybackStatePlaying:
                [MainPlayer pause];
                break;

            default:
                break;
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self updateUI];
    [self updateButtonStyle];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    [_playerView setFrame:self.view.bounds];

    [MainPlayer.nowPlayingItem.artwork loadArtworkImageWithSize:_playerView.imageView.bounds.size completion:^(UIImage * _Nonnull image) {
        mainDispatch(^{
            [self.playerView.imageView setImage:image];
        });
    }];

    //[self updateUI];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)updateUI{
    MPMediaItem *nowPlayingItem = MainPlayer.nowPlayingItem;
    if (!nowPlayingItem) {
        [self.playerView.heartSwitch setEnabled:NO];
        [self.playerView.nameLabel setText:@"当前无歌曲播放"];
        [self.playerView.artistLabel setText:@"----"];
        return;
    }

    //播放第三方音乐时没有playbackStoreID, 从而控制喜欢开关是否有效(但4G网络播放未开启时,可能也没有playbackStoreID)
    [MainPlayer nowPlayingSong:^(Song * _Nullable song) {

    }];

    [self.playerView.heartSwitch setEnabled:YES];
    [self.playerView.nameLabel setText:nowPlayingItem.title];
    [self.playerView.artistLabel setText:nowPlayingItem.artist];

    //延迟0.1秒加载图片,(不延迟,子视图还未布局好,就不能拿到最后的view的大小)
    [nowPlayingItem.artwork loadArtworkImageWithSize:_playerView.bounds.size completion:^(UIImage * _Nonnull image) {
        mainDispatch(^{
            [self.playerView.imageView setImage:image];
        });
    }];

}
- (MMPlayerView *)playerView{
    if (!_playerView) {
        _playerView = [[MMPlayerView alloc] init];
    }
    return _playerView;
}

- (void)updateButtonStyle{
    switch (MainPlayer.playbackState) {
        case MPMusicPlaybackStatePlaying:
            [self.playerView.play setStyle:MMPlayerButtonPauseStyle];
            break;

        case MPMusicPlaybackStateStopped:
            [self.playerView.play setStyle:MMPlayerButtonStopStyle];
            break;
        case MPMusicPlaybackStateInterrupted:
        case MPMusicPlaybackStatePaused:
            [self.playerView.play setStyle:MMPlayerButtonPlayStyle];
            break;

        default:
            break;
    }
}

//控制按钮动画
- (void)animationButton:(UIView*)sender{
    [UIView animateWithDuration:0.2 animations:^{
        [sender setTransform:CGAffineTransformMakeScale(0.88, 0.88)];
    } completion:^(BOOL finished) {
        //恢复
        [UIView animateWithDuration:0.2 animations:^{
            [sender setTransform:CGAffineTransformIdentity];
        }];
    }];
}

@end
