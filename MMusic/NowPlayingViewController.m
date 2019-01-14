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

#import "MMDataStack.h"
#import "MMCDMO_Song.h"

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

- (instancetype)init{
    if (self = [super init]) {
        _playerView = [[MMPlayerView alloc] init];
        [self.view addSubview:_playerView];
    }
    return self;
}

# pragma mark - lift cycle

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self updateCurrentItemMetadata];
}

- (void)viewDidLoad{
    [super viewDidLoad];




    [[NSNotificationCenter defaultCenter] addObserverForName:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        //[self updateButtonImage];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self updateCurrentItemMetadata];

        NSLog(@"now id =%@",MainPlayer.nowPlayingItem.playbackStoreID);

    }];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    [_playerView setFrame:self.view.bounds];
}


#pragma mark - button animation
- (void)animationButton:(UIButton*)sender{
    [UIView animateWithDuration:0.2 animations:^{
        [sender setTransform:CGAffineTransformMakeScale(0.88, 0.88)];
    } completion:^(BOOL finished) {
        //恢复
        [UIView animateWithDuration:0.2 animations:^{
            [sender setTransform:CGAffineTransformIdentity];
        }];
    }];
}



-(void)updateCurrentItemMetadata{
    MPMediaItem *nowPlayingItem = MainPlayer.nowPlayingItem;
    NSString *identifier = MainPlayer.nowPlayingItem.playbackStoreID;

    if (!nowPlayingItem) {
        [self.playerView.heartSwitch setEnabled:NO];

        [self.playerView.nameLabel setText:@"当前无歌曲播放"];
        [self.playerView.artistLabel setText:@"----"];
        return;
    }


//    //播放的时候, 有可能在播放第三方音乐, 从而控制喜欢开关是否有效(但4G网络播放未开启时,可能也没有playbackStoreID)
    self.playerView.heartSwitch.enabled = identifier ? YES  : NO;

    [self.playerView.nameLabel setText:nowPlayingItem.title];
    [self.playerView.artistLabel setText:nowPlayingItem.artist];

    [nowPlayingItem.artwork loadArtworkImageWithSize:self.playerView.imageView.bounds.size completion:^(UIImage * _Nonnull image) {
        [self.playerView.imageView setImage:image];
    }];

}

@end
