//
//  PopupView.m
//
//  Created by 🐙怪兽 on 2018/11/5.
//  Copyright © 2018 com.😈. All rights reserved.
//


#import <MediaPlayer/MediaPlayer.h>
#import "PopupView.h"
#import "Masonry/Masonry.h"


@implementation PopupView


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {

        
        _imageView = [[UIImageView alloc] init];
        _titleLabel = [[UILabel alloc] init];
        _playButton = [[UIButton alloc] init];
        _nextButton = [[UIButton alloc] init];


        [self addSubview:_imageView];
        [self addSubview:_titleLabel];
        [self addSubview:_playButton];
        [self addSubview:_nextButton];

        [self updateInfoWithItem:MainPlayer.nowPlayingItem];
        [self updateState:MainPlayer.playbackState];

        [_nextButton setImage:[UIImage imageNamed:@"nextFwd"] forState:UIControlStateNormal];
        [_nextButton addTarget:self action:@selector(ButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_playButton addTarget:self action:@selector(playButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }

    // 监听播放状态
    [[NSNotificationCenter defaultCenter] addObserverForName:MPMusicPlayerControllerPlaybackStateDidChangeNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification * _Nonnull note){
       [self updateState:MainPlayer.playbackState];
    }];
    //播放item
    [[NSNotificationCenter defaultCenter] addObserverForName:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self updateInfoWithItem:MainPlayer.nowPlayingItem];
    }];

    return self;
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:nil];
}
- (void)layoutSubviews{

    UIEdgeInsets spacing = UIEdgeInsetsMake(4, 8, 4, 4);
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(spacing.top);
        make.left.mas_equalTo(self).offset(spacing.left);
        make.bottom.mas_equalTo(self).offset(-spacing.bottom);
        CGFloat w = CGRectGetHeight(self.bounds) - (spacing.top+spacing.bottom);
        make.width.mas_equalTo(w);
    }];

    [_nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.imageView.mas_top);
        make.bottom.mas_equalTo(self.imageView.mas_bottom);
        make.right.mas_equalTo(self.mas_right).offset(-spacing.left);
        CGFloat w = CGRectGetHeight(self.bounds)-(spacing.top+spacing.bottom);
        make.width.mas_equalTo(w);
    }];

    [_playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.imageView.mas_top);
        make.bottom.mas_equalTo(self.imageView.mas_bottom);
        make.right.mas_equalTo(self.nextButton.mas_left).offset(-spacing.right);
        CGFloat w = CGRectGetHeight(self.bounds)-(spacing.top+spacing.bottom);
        make.width.mas_equalTo(w);
    }];

    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.imageView.mas_top);
        make.left.mas_equalTo(self.imageView.mas_right).offset(spacing.left);
        make.bottom.mas_equalTo(self.imageView.mas_bottom); //显式约束高度, 对齐
        make.right.mas_equalTo(self.playButton.mas_left).offset(-spacing.right);
    }];

    [super layoutSubviews];
}

- (void)updateInfoWithItem:(MPMediaItem*)nowItem {
    [_titleLabel setText:nowItem.title];
    [_imageView setImage:[nowItem.artwork imageWithSize:CGSizeMake(50, 50)]];
}

- (void)updateState:(MPMusicPlaybackState)state {
    switch (state) {
        case MPMusicPlaybackStateSeekingBackward:
        case MPMusicPlaybackStateSeekingForward:
        case MPMusicPlaybackStateInterrupted:
        case MPMusicPlaybackStatePaused:
        case MPMusicPlaybackStateStopped:
            [_playButton setImage:[UIImage imageNamed:@"play-1"] forState:UIControlStateNormal];
            break;

        case MPMusicPlaybackStatePlaying:
            [_playButton setImage:[UIImage imageNamed:@"pause-1"] forState:UIControlStateNormal];
            break;
    }
}

- (void)ButtonClick:(UIButton*)button{
    [MainPlayer skipToNextItem];
}

- (void)playButtonClick:(UIButton*)button{
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
}

@end
