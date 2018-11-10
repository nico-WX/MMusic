//
//  RedViewController.m
//  ScrollPage
//
//  Created by 🐙怪兽 on 2018/11/8.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import "NowPlayingViewController.h"
#import "NowPlayingViewController+Layout.h"
#import "NowPlayingViewController+UpdateButtonState.h"

#import "PlayProgressView.h"
#import "MySwitch.h"


#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <Masonry.h>


@interface NowPlayingViewController ()

@end

static NowPlayingViewController *_instance;
@implementation NowPlayingViewController

- (instancetype)init{
    if (self = [super init]) {
        _artworkView        = [UIImageView new];
        _playProgressView   = [PlayProgressView new];
        _songNameLabel      = [UILabel new];
        _artistLabel        = [UILabel new];
        _previousButton     = [UIButton new];
        _playButton         = [UIButton new];
        _nextButton         = [UIButton new];
        _heartSwitch        = [MySwitch new];

        [self.view addSubview:_heartSwitch];
        [self.view addSubview:_artworkView];
        [self.view addSubview:_playProgressView];
        [self.view addSubview:_songNameLabel];
        [self.view addSubview:_artistLabel];
        [self.view addSubview:_previousButton];
        [self.view addSubview:_playButton];
        [self.view addSubview:_nextButton];

        
        [_songNameLabel setFont:[UIFont systemFontOfSize:24]];
        [_songNameLabel setAdjustsFontSizeToFitWidth:YES];
        [_artistLabel setTextColor:UIColor.grayColor];

        [[NSNotificationCenter defaultCenter] addObserverForName:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            [self updatePlayerButtonUI];
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {

        }];
    }
    return self;
}

+ (instancetype)sharePlayerViewController {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    //防止同时访问
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_instance){
            _instance = [super allocWithZone:zone];
        }
    });
    return _instance;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}
- (void)updatePlayerButtonUI {
    CGFloat h = CGRectGetHeight(self.view.frame);
    //popup state
    if (h<100) {
        switch (MainPlayer.playbackState) {
            case MPMusicPlaybackStateStopped:
            case MPMusicPlaybackStatePaused:
            case MPMusicPlaybackStateInterrupted:
                [_playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
                break;

            case MPMusicPlaybackStatePlaying:
                [_playButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
                break;

            default:
                break;
        }
        [_playButton setImage:[UIImage imageNamed:@"nextFwd"] forState:UIControlStateNormal];

    }else{
        //open state
        [_previousButton setImage:[UIImage imageNamed:@"nowPlaying_prev"] forState:UIControlStateNormal];
        [_nextButton setImage:[UIImage imageNamed:@"nowPlaying_next"] forState:UIControlStateNormal];
        switch (MainPlayer.playbackState) {
            case MPMusicPlaybackStatePaused:
            case MPMusicPlaybackStateStopped:
            case MPMusicPlaybackStateInterrupted:
                [_playButton setImage:[UIImage imageNamed:@"nowPlaying_play"] forState:UIControlStateNormal];
                break;
            case MPMusicPlaybackStatePlaying:
                [_playButton setImage:[UIImage imageNamed:@"nowPlaying_pause"] forState:UIControlStateNormal];
                break;
            default:
                break;
        }
    }
}





- (void)popupViewDidOpenWithBounds:(CGRect)bounds{
    NSLog(@">>>>>>>>>> open");
    //[self openStateLayout];
}

- (void)popupViewDidCloseWithBounds:(CGRect)bounds{
    NSLog(@">>>>> close");
   // [self popupStateLayout];
}


@end
