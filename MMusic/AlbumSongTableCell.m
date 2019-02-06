//
//  AlbumSongTableCell.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/22.
//  Copyright © 2019 com.😈. All rights reserved.
//
#import <NAKPlaybackIndicatorView.h>
#import <MediaPlayer/MediaPlayer.h>
#import <Masonry.h>

#import "AlbumSongTableCell.h"
#import "Song.h"

@interface AlbumSongTableCell ()
@property(nonatomic,strong) NAKPlaybackIndicatorView *playbackIndicatorView;
@property(nonatomic,strong) UILabel *indexLabel;
@property(nonatomic,strong) UILabel *nameLabel;

@end

@implementation AlbumSongTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {

        NAKPlaybackIndicatorViewStyle *style = [NAKPlaybackIndicatorViewStyle iOS10Style];
        _playbackIndicatorView = [[NAKPlaybackIndicatorView alloc] initWithStyle:style];

        _indexLabel = [[UILabel alloc] init];
        [_indexLabel setTextColor:UIColor.grayColor];
        [_indexLabel setFont:[UIFont boldSystemFontOfSize:16]];
        [_indexLabel setTextAlignment:NSTextAlignmentCenter];
        
        _nameLabel = [[UILabel alloc] init];
        [_nameLabel setAdjustsFontSizeToFitWidth:YES];

        [self.contentView addSubview:_playbackIndicatorView];
        [self.contentView addSubview:_indexLabel];
        [self.contentView addSubview:_nameLabel];

        [[NSNotificationCenter defaultCenter] addObserverForName:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note){
            [self stateForSong:self.song];
        }];
        //播放状态改变, 修改指示状态
        [[NSNotificationCenter defaultCenter] addObserverForName:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            [self stateForSong:self.song];
        }];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];

    __weak typeof(self) weakSelf = self;
    UIView *superView = self.contentView;
    UIEdgeInsets insets = UIEdgeInsetsMake(8, 8, 8, 8);

    CGFloat w = CGRectGetHeight(superView.bounds) - (insets.top+insets.bottom);
    [_indexLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.mas_equalTo(superView).insets(insets);
        make.width.mas_equalTo(w);
    }];
    [_playbackIndicatorView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf.indexLabel);
    }];
    [_nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(superView);
        make.left.mas_equalTo(weakSelf.indexLabel.mas_right).inset(insets.left);
        make.right.mas_equalTo(superView).inset(60);
    }];
}

- (void)setSong:(Song *)song withIndex:(NSUInteger)index{
    if (_song != song) {
        _song = song;

        [_nameLabel setText:song.attributes.name];
        [_indexLabel setText:[NSString stringWithFormat:@"%02ld",index+1]];
        [self stateForSong:song];
    }
}


- (void)stateForSong:(Song*)song {

    BOOL isNowPlaying = [song isEqualToMediaItem:MainPlayer.nowPlayingItem];
    [_indexLabel setHidden:isNowPlaying];

    if (isNowPlaying) {
        switch (MainPlayer.playbackState) {
            case MPMusicPlaybackStatePlaying:
                [_playbackIndicatorView setState:NAKPlaybackIndicatorViewStatePlaying];
                break;

            default:
                [_playbackIndicatorView setState:NAKPlaybackIndicatorViewStatePaused];
                break;
        }
    }else{
        [_playbackIndicatorView setState:NAKPlaybackIndicatorViewStateStopped];
    }
    [self setNeedsDisplay];
}

@end
