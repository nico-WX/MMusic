//
//  NowPlayingViewController+UpdateUIState.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/10.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import "NowPlayingViewController.h"
#import "NowPlayingViewController+UpdateUIState.h"
#import "UIButton+BlockButton.h"

#import <MediaPlayer/MediaPlayer.h>

@implementation NowPlayingViewController (UpdateUIState)

- (void)addButtonActivation{
    //上一首
    [self.previousButton handleControlEvent:UIControlEventTouchUpInside withBlock:^{
        [self animationButton:self.previousButton];
        [MainPlayer skipToPreviousItem];
    }];

    // 播放或暂停
    [self.playButton handleControlEvent:UIControlEventTouchUpInside withBlock:^{
        [self animationButton:self.playButton];
        switch (MainPlayer.playbackState) {
            case MPMusicPlaybackStatePaused:
            case MPMusicPlaybackStateStopped:
            case MPMusicPlaybackStateInterrupted:
                [MainPlayer play];
                break;
            case MPMusicPlaybackStatePlaying:
                [MainPlayer pause];

            default:
                break;
        }
    }];

    //下一首
    [self.nextButton handleControlEvent:UIControlEventTouchUpInside withBlock:^{
        [self animationButton:self.nextButton];
        [MainPlayer skipToNextItem];
    }];
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

- (void)updateButton{
    CGFloat h = CGRectGetHeight(self.view.frame);
    //popup state
    if (h<100) {
        // title FontSize
        [self.songNameLabel setFont:[UIFont systemFontOfSize:18]];
        [self.nextButton setImage:[UIImage imageNamed:@"nextFwd"] forState:UIControlStateNormal];
        switch (MainPlayer.playbackState) {
            case MPMusicPlaybackStateStopped:
            case MPMusicPlaybackStatePaused:
            case MPMusicPlaybackStateInterrupted:
                [self.playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
                break;

            case MPMusicPlaybackStatePlaying:
                [self.playButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
                break;

            default:
                break;
        }

    }else{
        //open state
        // title FontSize
        [self.songNameLabel setFont:[UIFont systemFontOfSize:26]];
        [self.previousButton setImage:[UIImage imageNamed:@"nowPlaying_prev"] forState:UIControlStateNormal];
        [self.nextButton setImage:[UIImage imageNamed:@"nowPlaying_next"] forState:UIControlStateNormal];
        switch (MainPlayer.playbackState) {
            case MPMusicPlaybackStatePaused:
            case MPMusicPlaybackStateStopped:
            case MPMusicPlaybackStateInterrupted:
                [self.playButton setImage:[UIImage imageNamed:@"nowPlaying_play"] forState:UIControlStateNormal];
                break;
            case MPMusicPlaybackStatePlaying:
                [self.playButton setImage:[UIImage imageNamed:@"nowPlaying_pause"] forState:UIControlStateNormal];
                break;
            default:
                break;
        }
    }
}
@end
