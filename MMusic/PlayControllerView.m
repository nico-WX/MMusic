//
//  PlayControllerView.m
//  MMusic
//
//  Created by Magician on 2018/4/14.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import "PlayControllerView.h"
#import <Masonry.h>
#import <MediaPlayer/MediaPlayer.h>


@interface PlayControllerView()
@end

@implementation PlayControllerView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        //按钮
        _previous   = [[UIButton alloc] init];
        _play       = [[UIButton alloc] init];
        _next       = [[UIButton alloc] init];

        //绑定按钮事件
        [_previous addTarget:self action:@selector(previousButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_play addTarget:self action:@selector(playButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_next addTarget:self action:@selector(nextButtonClick:) forControlEvents:UIControlEventTouchUpInside];

        //按钮添加到辅层
        [self addSubview:_previous];
        [self addSubview:_play];
        [self addSubview:_next];

        [self updateWithState:MainPlayer.playbackState];
        [_previous setImage:[UIImage imageNamed:@"nowPlaying_prev"] forState:UIControlStateNormal];
        [_next setImage:[UIImage imageNamed:@"nowPlaying_next"] forState:UIControlStateNormal];

        [[NSNotificationCenter defaultCenter] addObserverForName:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            [self updateWithState:MainPlayer.playbackState];
        }];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:nil];
}

- (void)layoutSubviews{

    NSLog(@"layout");

    CGFloat centerX = CGRectGetMidX(self.bounds);
    CGFloat centerY = CGRectGetMidY(self.bounds);

    //按钮size
    CGFloat h = CGRectGetHeight(self.bounds);
    CGFloat w = h;

    CGFloat y = centerY - h/2;
    CGFloat pre_x = centerX/2 - w/2;
    CGFloat play_x = centerX - w/2;
    CGFloat next_x = centerX+(centerX/2) - w/3;

    CGRect preFrame = CGRectMake(pre_x, y, w, h);
    CGRect playFrame = CGRectMake(play_x, y, w, h);
    CGRect nextFrame = CGRectMake(next_x, y, w, h);

    [self.previous setFrame:preFrame];
    [self.play setFrame:playFrame];
    [self.next setFrame:nextFrame];

    [super layoutSubviews];
}


- (void)updateWithState:(MPMusicPlaybackState)state {
    switch (state) {
        case MPMusicPlaybackStatePlaying:
            [_play setImage:[UIImage imageNamed:@"nowPlaying_pause"] forState:UIControlStateNormal];
            break;
            
        case MPMusicPlaybackStateStopped:
        case MPMusicPlaybackStatePaused:
        case MPMusicPlaybackStateInterrupted:
            [_play setImage:[UIImage imageNamed:@"nowPlaying_play"] forState:UIControlStateNormal];
            break;

        default:
            break;
    }
}

# pragma mark - button action
- (void)previousButtonClick:(UIButton*)button {
    [MainPlayer skipToPreviousItem];
    [self animationButton:button];
}
- (void)playButtonClick:(UIButton*)button {
    [self animationButton:button];
    switch (MainPlayer.playbackState) {
        case MPMusicPlaybackStateInterrupted:
        case MPMusicPlaybackStatePaused:
        case MPMusicPlaybackStateStopped:
            [MainPlayer play];
            break;
        case MPMusicPlaybackStatePlaying:
            [MainPlayer pause];
            break;
        default:
            break;
    }
}
- (void)nextButtonClick:(UIButton*)button {
    [MainPlayer skipToNextItem];
    [self animationButton:button];
}

#pragma mark - button animation
- (void)animationButton:(UIButton*)sender{
    [UIView animateWithDuration:0.2 animations:^{
        [sender setTransform:CGAffineTransformMakeScale(0.88, 0.88)];
    } completion:^(BOOL finished) {
        if (finished) {
            //恢复
            [UIView animateWithDuration:0.2 animations:^{
                [sender setTransform:CGAffineTransformIdentity];
            }];
        }
    }];
}

@end
