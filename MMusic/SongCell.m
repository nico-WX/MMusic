//
//  SongCell.m
//  MMusic
//
//  Created by Magician on 2018/3/11.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <NAKPlaybackIndicatorView.h>
#import <Masonry.h>

#import "PlayerContentViewController.h"
#import "SongCell.h"
#import "Song.h"

@interface SongCell()

@property(nonatomic, strong) NAKPlaybackIndicatorView   *playbackIndicatorView;
@property(nonatomic, strong, readonly) UILabel          *nameLabel;
@property(nonatomic, strong, readonly) UILabel          *artistLabel;
@property(nonatomic, strong, readonly) UILabel          *durationLabel;
@end

@implementation SongCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {

        NAKPlaybackIndicatorViewStyle *style = [NAKPlaybackIndicatorViewStyle iOS10Style];
        _playbackIndicatorView = [[NAKPlaybackIndicatorView alloc] initWithStyle:style];

        _numberLabel = UILabel.new;
        [_numberLabel setTextAlignment:NSTextAlignmentCenter];
        [_numberLabel setFont:[UIFont boldSystemFontOfSize:16]];

        _nameLabel = UILabel.new;
        [_nameLabel setAdjustsFontSizeToFitWidth:YES];

        _artistLabel = UILabel.new;
        [_artistLabel setFont:[UIFont systemFontOfSize:12]];
        [_artistLabel setTextColor:[UIColor grayColor]];

        _durationLabel = UILabel.new;
        [_durationLabel setTextAlignment:NSTextAlignmentCenter];
        [_durationLabel setFont:[UIFont italicSystemFontOfSize:12]];

        [self.contentView addSubview:_playbackIndicatorView];
        [self.contentView addSubview:_numberLabel];
        [self.contentView addSubview:_nameLabel];
        [self.contentView addSubview:_artistLabel];
        [self.contentView addSubview:_durationLabel];

        [self setupLayout];

        //播放项目改变  修改播放指示cell
        [[NSNotificationCenter defaultCenter] addObserverForName:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            [self stateForSong:self.song];
        }];
        //播放状态改变, 修改指示状态
        [[NSNotificationCenter defaultCenter] addObserverForName:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            [self stateForSong:self.song];
        }];
    }
    return self;
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)prepareForReuse{
    [super prepareForReuse];
    _numberLabel.text = nil;
    _nameLabel.text = nil;
    _artistLabel.text = nil;
    _durationLabel.text = nil;
    _song = nil;

}

-(void) setupLayout{
    UIEdgeInsets padding = UIEdgeInsetsMake(2, 2, 2, 2);
    NSUInteger timer = 3;
    UIView *superview = self.contentView;
    __weak typeof(self) weakSelf = self;

    [self.numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superview.mas_top).offset(padding.top);
        make.left.mas_equalTo(superview.mas_left).offset(padding.left);
        make.bottom.mas_equalTo(superview.mas_bottom).offset(-padding.bottom);
        CGFloat w = CGRectGetHeight(superview.frame)-(padding.top+padding.bottom);
        make.width.mas_equalTo(w);
    }];

    [self.playbackIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf.numberLabel).insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];

    [self.durationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superview.mas_top);
        make.right.mas_equalTo(superview.mas_right);
        make.bottom.mas_equalTo(superview.mas_bottom);
        make.width.mas_equalTo(66);
    }];

    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superview.mas_top);
        make.left.mas_equalTo(weakSelf.numberLabel.mas_right).offset(padding.left*timer);
        make.right.mas_equalTo(weakSelf.durationLabel.mas_left).offset(-padding.right);
        CGFloat h = CGRectGetHeight(superview.frame)*0.6;
        make.height.mas_equalTo(h);
    }];

    [self.artistLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.nameLabel.mas_bottom);
        make.left.mas_equalTo(weakSelf.nameLabel.mas_left);
        make.right.mas_equalTo(weakSelf.nameLabel.mas_right);
        make.bottom.mas_equalTo(superview.mas_bottom);
    }];
}

#pragma mark - setter
-(void)setSong:(Song *)song{
    if (_song != song ) {
        _song = song;

        //设置歌曲信息
        self.nameLabel.text = self.song.name;
        self.artistLabel.text = self.song.artistName;
        NSTimeInterval duration = self.song.durationInMillis.doubleValue / 1000.0;
        NSString *durationText = [NSString stringWithFormat:@"%d:%02d",(int32_t)duration/60,(int32_t)duration%60];
        self.durationLabel.text = durationText;
        [self stateForSong:song];
    }
}

-(void) stateForSong:(Song*) song{
    MPMediaItem *item = MainPlayer.nowPlayingItem;
    if ([song isEqualToMediaItem:item]) {
        [self.numberLabel setHidden:YES];
        switch (MainPlayer.playbackState) {
            case MPMusicPlaybackStatePlaying:
                [self.playbackIndicatorView setState:NAKPlaybackIndicatorViewStatePlaying];
                break;

            default:
                [self.playbackIndicatorView setState:NAKPlaybackIndicatorViewStatePaused];
                break;
        }
    }else{
        [self.numberLabel setHidden:NO];
        [self.playbackIndicatorView setState:NAKPlaybackIndicatorViewStateStopped];
    }
    [self setNeedsDisplay];
}


@end
