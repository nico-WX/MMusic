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
    [self.previousButton handleControlEvent:UIControlEventTouchUpInside withBlock:^{
        [MainPlayer skipToPreviousItem];
        [self animationButton:self.previousButton];
    }];
    [self.playButton handleControlEvent:UIControlEventTouchUpInside withBlock:^{
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
        [self animationButton:self.playButton];
    }];
    [self.nextButton handleControlEvent:UIControlEventTouchUpInside withBlock:^{
        [MainPlayer skipToNextItem];
        [self animationButton:self.nextButton];
    }];
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

- (void)updateButton{
    CGFloat h = CGRectGetHeight(self.view.frame);
    //popup state
    if (h<100) {
        // title FontSize
         [self.songNameLabel setFont:[UIFont systemFontOfSize:20]];
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
        [self.nextButton setImage:[UIImage imageNamed:@"nextFwd"] forState:UIControlStateNormal];

    }else{
        //open state
        // title FontSize
        [self.songNameLabel setFont:[UIFont systemFontOfSize:24]];
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
