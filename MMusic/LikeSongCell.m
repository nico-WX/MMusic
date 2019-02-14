//
//  LikeSongCell.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/2/10.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "LikeSongCell.h"
#import "SongManageObject.h"
#import "MPMediaItemArtwork+Exchange.h"

#import <Masonry.h>
#import <NAKPlaybackIndicatorView.h>
#import <MediaPlayer/MediaPlayer.h>

@interface LikeSongCell()
@property(nonatomic, strong) NAKPlaybackIndicatorView *playbackIndicator;
@property(nonatomic, strong) UIImageView *artworkView;
@property(nonatomic, strong) UILabel *nameLabel;
@property(nonatomic, strong) UILabel *artistLabel;
@end

@implementation LikeSongCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _artworkView = [[UIImageView alloc] init];
        _nameLabel = [[UILabel alloc] init];
        _artistLabel = [[UILabel alloc] init];
        NAKPlaybackIndicatorViewStyle *style = [NAKPlaybackIndicatorViewStyle iOS10Style];
        _playbackIndicator = [[NAKPlaybackIndicatorView alloc] initWithStyle:style];

        [self.contentView addSubview:_artworkView];
        [self.contentView addSubview:_nameLabel];
        [self.contentView addSubview:_artistLabel];
        [self.contentView addSubview:_playbackIndicator];

        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(updatePlaybackIndicatorState) name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:nil];
        [center addObserver:self selector:@selector(updatePlaybackIndicatorState) name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:nil];
    }
    return self;
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews{
    [super layoutSubviews];

    UIEdgeInsets insets = UIEdgeInsetsMake(8, 8, 8, 8);
    __weak typeof(self) weakSelf = self;
    UIView *superView = self.contentView;

    [_artworkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.mas_equalTo(superView).insets(insets);
        CGFloat w = CGRectGetHeight(superView.bounds)-(insets.top+insets.bottom);
        make.width.mas_equalTo(w);
    }];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(superView.mas_centerY);
        make.left.mas_equalTo(weakSelf.artworkView.mas_right).insets(insets);
        make.right.mas_equalTo(superView).insets(insets);
    }];
    [_artistLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superView.mas_centerY);
        make.left.right.mas_equalTo(weakSelf.nameLabel);
    }];
    [_playbackIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf.artworkView);
    }];

}
- (void)setSongManageObject:(SongManageObject *)songManageObject{
    if (_songManageObject != songManageObject) {
        _songManageObject = songManageObject;

        [_artworkView setImageWithURLPath:[songManageObject.artwork valueForKey:@"url"]];
        [_nameLabel setText:songManageObject.name];
        [_artistLabel setText:songManageObject.artistName];
        [self updatePlaybackIndicatorState];
    }
}

- (void)setMediaItem:(MPMediaItem *)mediaItem{
    if (_mediaItem != mediaItem) {
        _mediaItem = mediaItem;

        [_nameLabel setText:mediaItem.title];
        [_artistLabel setText:mediaItem.artist];
        if (!_artistLabel.text) {
            [_artistLabel setText:mediaItem.albumTitle];
        }

        MPMediaItemArtwork *artwork = mediaItem.artwork;
        [artwork loadArtworkImageWithSize:_artworkView.bounds.size completion:^(UIImage * _Nonnull image) {
            [self.artworkView setImage:image];
        }];
        
    }
}

- (void)updatePlaybackIndicatorState{
    BOOL isNowPlaying = [MainPlayer.nowPlayingItem.playbackStoreID isEqualToString:_songManageObject.identifier];

    if (isNowPlaying) {
        [UIView animateWithDuration:0.35 animations:^{
            [self.artworkView setAlpha:0.35];
        }];

        switch (MainPlayer.playbackState) {
            case MPMusicPlaybackStatePaused:
                [self.playbackIndicator setState:NAKPlaybackIndicatorViewStatePaused];
                break;
            case MPMusicPlaybackStatePlaying:
            case MPMusicPlaybackStateSeekingForward:
            case MPMusicPlaybackStateSeekingBackward:
                [self.playbackIndicator setState:NAKPlaybackIndicatorViewStatePlaying];
                break;

            default:
                [self.playbackIndicator setState:NAKPlaybackIndicatorViewStateStopped];
                break;
        }
    }else{
        [UIView animateWithDuration:0.35 animations:^{
            [self.artworkView setAlpha:1];
            [self.playbackIndicator setState:NAKPlaybackIndicatorViewStateStopped];
        }];
    }
}
@end
