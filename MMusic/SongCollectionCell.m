//
//  ChartsSongCell.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/18.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "SongCollectionCell.h"
#import "Resource.h"
#import "Song.h"

#import <Masonry.h>
#import <NAKPlaybackIndicatorView.h>
#import <MediaPlayer/MediaPlayer.h>

@interface SongCollectionCell ()
@property(nonatomic, strong)UIImageView *lineView;
@property(nonatomic, strong)NAKPlaybackIndicatorView *playbackIndicatorView;

@property(nonatomic) id stateObserver;
@property(nonatomic) id changeObserver;
@end

@implementation SongCollectionCell

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {

        [self.titleLabel setTextAlignment:NSTextAlignmentLeft];
        [self.subTitleLable setTextAlignment:NSTextAlignmentLeft];

        _lineView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_lineView setBackgroundColor:UIColor.lightGrayColor];
        [_lineView setAlpha:0.3]; //线条视觉更细

        NAKPlaybackIndicatorViewStyle *style = [NAKPlaybackIndicatorViewStyle iOS10Style];
        _playbackIndicatorView = [[NAKPlaybackIndicatorView alloc] initWithStyle:style];

        [self.contentView addSubview:_playbackIndicatorView];
        [self.contentView addSubview:_lineView];

        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        _stateObserver = [center addObserverForName:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            [self stateForSong:[Song instanceWithResource:self.resource]];
        }];
        _changeObserver = [center addObserverForName:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            [self stateForSong:[Song instanceWithResource:self.resource]];
        }];
    }
    return self;
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:_stateObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:_changeObserver];
    _stateObserver = nil;
    _changeObserver = nil;
}
- (void)didMoveToSuperview{
    [super didMoveToSuperview];

    [self stateForSong:[Song instanceWithResource:self.resource]];
}



- (void)layoutSubviews{
    [super layoutSubviews];

    UIEdgeInsets insets = UIEdgeInsetsMake(4, 4, 4, 4);
    UIView *superView = self.contentView;
    __weak typeof(self) weakSelf = self;

    [_lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        UIEdgeInsets lineInsets = UIEdgeInsetsMake(0, 40, 0, 20);
        make.top.mas_equalTo(superView);
        make.left.right.mas_equalTo(superView).insets(lineInsets);
        make.height.mas_equalTo(1);
    }];

    [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        [make setRemoveExisting:YES];
    }];
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        [make setRemoveExisting:YES];
    }];
    [self.subTitleLable mas_remakeConstraints:^(MASConstraintMaker *make) {
        [make setRemoveExisting:YES];
    }];

    [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.mas_equalTo(superView).insets(insets);
        CGFloat w = CGRectGetHeight(superView.bounds)-(insets.top+insets.bottom);
        make.width.mas_equalTo(w);
    }];

    [_playbackIndicatorView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf.imageView);
    }];


    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(superView.mas_centerY);
        make.left.mas_equalTo(weakSelf.imageView.mas_right).inset(insets.left);
        make.right.mas_equalTo(superView);
    }];
    [self.subTitleLable mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.titleLabel.mas_bottom).inset(0);
        make.left.mas_equalTo(weakSelf.imageView.mas_right).inset(insets.left);
    }];

}

- (void)stateForSong:(Song*)song {

    BOOL isNowPlaying = [song isEqualToMediaItem:MainPlayer.nowPlayingItem];

    [UIView animateWithDuration:1 animations:^{
        [self.imageView setAlpha:!isNowPlaying];
    } completion:^(BOOL finished) {
        [self.imageView setHighlighted:isNowPlaying];
    }];


    if (isNowPlaying) {
        switch (MainPlayer.playbackState) {
            case MPMusicPlaybackStatePlaying:
            case MPMusicPlaybackStateSeekingForward:
            case MPMusicPlaybackStateSeekingBackward:
                NSLog(@"current =%@",[NSThread currentThread]);
                [_playbackIndicatorView setState:NAKPlaybackIndicatorViewStatePlaying];
                [_playbackIndicatorView updateFocusIfNeeded];
                break;

            case MPMusicPlaybackStatePaused:
                 [_playbackIndicatorView setState:NAKPlaybackIndicatorViewStatePaused];
                break;

            case MPMusicPlaybackStateStopped:
                [_playbackIndicatorView setState:NAKPlaybackIndicatorViewStateStopped];

            default:
                break;
        }
    }else{
        [_playbackIndicatorView setState:NAKPlaybackIndicatorViewStateStopped];
    }

    [self setNeedsDisplay];
}

#pragma mark - setter/getter
- (void)setResource:(Resource *)resource{
    [super setResource:resource];

    [self stateForSong:[Song instanceWithResource:resource]];
    if ([resource.type isEqualToString:@"songs"]) {
        [self.subTitleLable setText:[resource.attributes valueForKey:@"artistName"]];
    }
}
@end
