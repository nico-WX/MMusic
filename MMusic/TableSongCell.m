//
//  TableSongCell.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/2/12.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import <Masonry.h>
#import <NAKPlaybackIndicatorView.h>

#import "TableSongCell.h"
#import "Song.h"
#import "SongManageObject.h"
#import "Artwork.h"

@interface TableSongCell ()
@property(nonatomic,strong)NAKPlaybackIndicatorView *playIndicator;
@property(nonatomic,copy) NSString *identifier;
@end

@implementation TableSongCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _nameLabel = [[UILabel alloc] init];
        _artistLabel= [[UILabel alloc] init];
        _artworkView = [[UIImageView alloc] init];
        NAKPlaybackIndicatorViewStyle *style =[NAKPlaybackIndicatorViewStyle iOS10Style];
        _playIndicator = [[NAKPlaybackIndicatorView alloc] initWithStyle:style];

        [_artistLabel setTextColor:UIColor.grayColor];
        [_artistLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];

        [self.contentView addSubview:_artworkView];
        [self.contentView addSubview:_nameLabel];
        [self.contentView addSubview:_artistLabel];
        [self.contentView addSubview:_playIndicator];

        [[NSNotificationCenter defaultCenter] addObserverForName:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            mainDispatch(^{
                [self updateState];
            });
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            mainDispatch(^{
                [self updateState];
            });
        }];

    }
    return self;
}
- (void)updateState{
    NSString *nowIdentifier = MainPlayer.nowPlayingItem.playbackStoreID;
    if ([nowIdentifier isEqualToString:self.identifier]) {
        [UIView animateWithDuration:0.35 animations:^{
            [self.artworkView setAlpha:0.35];
        }];

        switch (MainPlayer.playbackState) {
            case MPMusicPlaybackStatePaused:
                [self.playIndicator setState:NAKPlaybackIndicatorViewStatePaused];
                break;
            case MPMusicPlaybackStatePlaying:
            case MPMusicPlaybackStateSeekingForward:
            case MPMusicPlaybackStateSeekingBackward:
                [self.playIndicator setState:NAKPlaybackIndicatorViewStatePlaying];
                break;

            default:
                [self.playIndicator setState:NAKPlaybackIndicatorViewStateStopped];
                break;
        }
    }else{
        [UIView animateWithDuration:0.35 animations:^{
            [self.artworkView setAlpha:1];
        }];
        [self.playIndicator setState:NAKPlaybackIndicatorViewStateStopped];
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)layoutSubviews{
    [super layoutSubviews];

    UIEdgeInsets insets = UIEdgeInsetsMake(4, 4, 4, 4);
    UIView *superview = self.contentView;
    __weak typeof(self) weakSelf = self;

    [self.artworkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.mas_equalTo(superview).insets(insets);
        CGFloat w = CGRectGetHeight(superview.bounds)-(insets.top+insets.bottom);
        make.width.mas_equalTo(w);
    }];
    [self.playIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf.artworkView);
    }];

    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(superview.mas_centerY);
        make.left.mas_equalTo(weakSelf.artworkView.mas_right).insets(insets);
        make.right.mas_equalTo(superview).insets(insets);
    }];
    [self.artistLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superview.mas_centerY);
        make.left.right.mas_equalTo(weakSelf.nameLabel);
    }];
}

- (void)configureForSong:(Song *)song{
    mainDispatch(^{
        self.identifier = song.identifier;
        self.nameLabel.text = song.name;
        self.artistLabel.text = song.artistName;
        [self.artworkView setImageWithURLPath:song.artwork.url];

        [self updateState];
        [self setNeedsDisplay];
    });
}
- (void)configureForSongManageObject:(SongManageObject *)songMO{
    mainDispatch(^{
        self.identifier = songMO.identifier;
        self.nameLabel.text = songMO.name;
        self.artistLabel.text = songMO.artistName;
        NSString *url = [songMO.artwork valueForKey:@"url"];
        [self.artworkView setImageWithURLPath:url];

        [self updateState];
        [self setNeedsDisplay];
    });
}
@end
