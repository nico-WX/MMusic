//
//  PlaylistSongTableCell.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/22.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import <Masonry.h>
#import <MediaPlayer/MediaPlayer.h>
#import <NAKPlaybackIndicatorView.h>

#import "PlaylistSongTableCell.h"
#import "Song.h"
#import "Artwork.h"

@interface PlaylistSongTableCell ()
@property(nonatomic, strong) NAKPlaybackIndicatorView *playbackIndicatorView;
@property(nonatomic, strong) UIImageView *artworkView;
@property(nonatomic, strong) UILabel *nameLabel;
@property(nonatomic, strong) UILabel *artistLabel;
@end

@implementation PlaylistSongTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        NAKPlaybackIndicatorViewStyle *style = [NAKPlaybackIndicatorViewStyle iOS10Style];
        _playbackIndicatorView = [[NAKPlaybackIndicatorView alloc] initWithStyle:style];

        _artworkView = [[UIImageView alloc] init];
        _nameLabel = [[UILabel alloc] init];
        _artistLabel = [[UILabel alloc] init];

        [_nameLabel setAdjustsFontSizeToFitWidth:YES];
        [_artistLabel setTextColor:UIColor.grayColor];
        [_artistLabel setFont:[UIFont systemFontOfSize:12]];

        [self.contentView addSubview:_artworkView];
        [self.contentView addSubview:_playbackIndicatorView];  //指示视图在 artwork上面
        [self.contentView addSubview:_nameLabel];
        [self.contentView addSubview:_artistLabel];

        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserverForName:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            [self stateForSong:self.song];
        }];
        [center addObserverForName:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            [self stateForSong:self.song];
        }];
    }
    return self;
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)layoutSubviews{
    [super layoutSubviews];

    __weak typeof(self) weakSelf = self;
    UIView *superView = self.contentView;
    UIEdgeInsets insets = UIEdgeInsetsMake(8, 8, 8, 8);
    CGFloat w = CGRectGetHeight(superView.bounds) - (insets.top+insets.bottom);

    [_artworkView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.mas_equalTo(superView).insets(insets);
        make.width.mas_equalTo(w);
    }];
    [_playbackIndicatorView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf.artworkView);
    }];

    [_nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(superView.mas_centerY);
        make.left.mas_equalTo(weakSelf.artworkView.mas_right).inset(insets.left);
        make.top.lessThanOrEqualTo(superView).inset(insets.top);
        make.right.mas_equalTo(superView).inset(60);
    }];
    [_artistLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superView.mas_centerY);
        make.left.right.mas_equalTo(weakSelf.nameLabel);
        make.bottom.mas_lessThanOrEqualTo(superView).inset(insets.bottom);
    }];
}

- (void)setSong:(Song *)song{
    if (_song != song) {
        _song = song;

        [_nameLabel setText:song.name];
        [_artistLabel setText:song.artistName];
        [_artworkView setImageWithURLPath:song.artwork.url];
        [self stateForSong:song];
    }
}


- (void)stateForSong:(Song*)song {

    BOOL isNowPlaying = [song isEqualToMediaItem:MainPlayer.nowPlayingItem];
    [_artworkView setHidden:isNowPlaying]; //item 相等, 显示播放指示视图, 隐藏imageview

    if (isNowPlaying) {
        switch (MainPlayer.playbackState) {
            case MPMusicPlaybackStatePlaying:
            case MPMusicPlaybackStateSeekingForward:
            case MPMusicPlaybackStateSeekingBackward:
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
