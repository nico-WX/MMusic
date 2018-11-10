//
//  NowPlayingViewController+UpdateUIState.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/10.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import "NowPlayingViewController.h"
#import "NowPlayingViewController+UpdateUIState.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation NowPlayingViewController (UpdateUIState)



- (void)updateButton{
    CGFloat h = CGRectGetHeight(self.view.frame);
    //popup state
    if (h<100) {
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
