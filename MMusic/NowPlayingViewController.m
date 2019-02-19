//
//  RedViewController.m
//  ScrollPage
//
//  Created by 🐙怪兽 on 2018/11/8.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import <Masonry.h>
#import "TabBarController.h"

#import "NowPlayingViewController.h"
#import "MPMusicPlayerController+ResourcePlaying.h"
#import "MPMediaItemArtwork+Exchange.h"

#import "PlayProgressView.h"
#import "MMHeartSwitch.h"
#import "PlayerView.h"
#import "MMPlayerButton.h"

#import "CoreDataStack.h"
#import "SongManageObject.h"

#import "Artwork.h"
#import "Song.h"

@interface NowPlayingViewController ()
@property(nonatomic, strong) PlayerView *playerView;
@end

@implementation NowPlayingViewController

#pragma mark - init

// 单例实现
SingleImplementation(PlayerViewController);


# pragma mark - lift cycle
- (void)viewDidLoad{
    [super viewDidLoad];

    //
    self.playerView = [[PlayerView alloc] init];
    [self.view addSubview:self.playerView];

    //播放器通知
    [[NSNotificationCenter defaultCenter] addObserverForName:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self updateButtonStyle];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self updateUI];
    }];

    //按钮事件, 心型开关内部已经定义好事件,不用处理
    __weak typeof(self) weakSelf = self;
    [_playerView.previous handleControlEvent:UIControlEventTouchUpInside withBlock:^{
        [weakSelf animationButton:weakSelf.playerView.previous];
        [MainPlayer skipToPreviousItem];
    }];
    [_playerView.next handleControlEvent:UIControlEventTouchUpInside withBlock:^{
        [weakSelf animationButton:weakSelf.playerView.next];
        [MainPlayer skipToNextItem];
    }];
    [_playerView.play handleControlEvent:UIControlEventTouchUpInside withBlock:^{
        [weakSelf animationButton:weakSelf.playerView.play];
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

    [_playerView.shareButton handleControlEvent:UIControlEventTouchUpInside withBlock:^{
        [MainPlayer nowPlayingSong:^(Song * _Nullable song) {
            [self shareSong:song];
        }];
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
    [self updateUI];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)shareSong:(Song*)song{
    NSString *name = song.name;
    NSURL *url = [NSURL URLWithString:song.url];

    if (name && url) {
        NSArray *item = @[name,url];

        UIActivity *activity = [[UIActivity alloc] init];
        UIActivityViewController *avc = [[UIActivityViewController alloc] initWithActivityItems:item applicationActivities:@[activity,]];

        [avc setCompletionWithItemsHandler:^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
            // activityType  分享方向
        }];
        //显示
        [self presentViewController:avc animated:YES completion:nil];
    }
}


-(void)updateUI{
    mainDispatch(^{
        MPMediaItem *nowPlayingItem = MainPlayer.nowPlayingItem;
        if (!nowPlayingItem) {
            [self.playerView.heartSwitch setEnabled:NO];
            [self.playerView.nameLabel setText:@"当前无歌曲播放"];
            [self.playerView.artistLabel setText:@"----"];
            return;
        }

        [self.playerView.heartSwitch setEnabled:YES];
        [self.playerView.nameLabel setText:nowPlayingItem.title];
        [self.playerView.artistLabel setText:nowPlayingItem.artist];
        if (nowPlayingItem.playbackStoreID.length < 2) {
            [self.playerView.heartSwitch setEnabled:NO];
        }

        CGSize size = self.playerView.imageView.bounds.size;
        if (nowPlayingItem.artwork) {
            [nowPlayingItem.artwork loadArtworkImageWithSize:size completion:^(UIImage * _Nonnull image) {
                [self.playerView.imageView setImage:image];
            }];
        }else{
            [MainPlayer nowPlayingSong:^(Song * _Nullable song) {
                [self.playerView.imageView setImageWithURLPath:song.artwork.url];
            }];
        }
    });
}


- (void)updateButtonStyle{
    switch (MainPlayer.playbackState) {
        case MPMusicPlaybackStatePlaying:
            [self.playerView.play setStyle:MMPlayerButtonPauseStyle];
            break;

        case MPMusicPlaybackStateStopped:
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
