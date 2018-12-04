//
//  SongCell.m
//  MMusic
//
//  Created by Magician on 2018/3/11.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <NAKPlaybackIndicatorView.h>
#import <Masonry.h>
#import <MediaPlayer/MediaPlayer.h>

#import "NowPlayingViewController.h"
#import "UIView+LayerImage.h"
#import "SongCell.h"
#import "Song.h"

@interface SongCell()

@property(nonatomic, strong) NAKPlaybackIndicatorView   *playbackIndicatorView;

@property(nonatomic, strong) UILabel          *nameLabel;
@property(nonatomic, strong) UILabel          *artistLabel;
@property(nonatomic, strong) UILabel          *durationLabel;
@property(nonatomic, strong) UILabel          *numberLabel;
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

        //[self setupLayout];

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

- (void)layoutSubviews{
    [super layoutSubviews];

    UIEdgeInsets padding = UIEdgeInsetsMake(2, 2, 2, 2);
    NSUInteger timer = 3;
    UIView *superview = self.contentView;
    __weak typeof(self) weakSelf = self;

    [self.numberLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superview).offset(padding.top);
        make.left.mas_equalTo(superview).offset(padding.left);
        make.bottom.mas_equalTo(superview).offset(-padding.bottom);
        CGFloat w = CGRectGetHeight(superview.bounds)-(padding.top+padding.bottom);
        make.width.mas_equalTo(w);
    }];

    [self.playbackIndicatorView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf.numberLabel);
    }];

    [self.durationLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superview.mas_top);
        make.right.mas_equalTo(superview.mas_right);
        make.bottom.mas_equalTo(superview.mas_bottom);
        make.width.mas_equalTo(CGRectGetHeight(superview.frame));
    }];

    [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.numberLabel.mas_right).offset(padding.left*timer);
        make.right.mas_equalTo(weakSelf.durationLabel.mas_left).offset(-padding.right);
        make.bottom.mas_equalTo(superview).offset(-CGRectGetMidY(superview.bounds));
        make.top.lessThanOrEqualTo(superview).offset(padding.top);

//        make.top.mas_equalTo(superview.mas_top);
//        CGFloat h = CGRectGetHeight(superview.frame)*0.6;
//        make.height.mas_equalTo(h);
    }];

    [self.artistLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.nameLabel.mas_bottom);
        make.left.mas_equalTo(weakSelf.nameLabel.mas_left);
        make.right.mas_equalTo(weakSelf.nameLabel.mas_right);
        make.bottom.mas_equalTo(superview.mas_bottom).mas_offset(-padding.bottom);
    }];
}

#pragma mark - setter

- (void)setSong:(Song *)song withIndex:(NSUInteger)index{
    if (_song != song) {

        _song = song;

        //设置歌曲信息
        [_numberLabel setText:[NSString stringWithFormat:@"%02ld",index+1]];
        [_nameLabel setText:song.name];
        [_artistLabel setText:song.artistName];

        NSTimeInterval duration = song.durationInMillis.doubleValue / 1000.0;
        NSString *durationText = [NSString stringWithFormat:@"%d:%02d",(int32_t)duration/60,(int32_t)duration%60];
        [_durationLabel setText:durationText];

        [self stateForSong:song];
    }
}

- (void)stateForSong:(Song*)song {

    if ([song isEqualToMediaItem:MainPlayer.nowPlayingItem]) {
        [_numberLabel setHidden:YES];
        switch (MainPlayer.playbackState) {
            case MPMusicPlaybackStatePlaying:
                [_playbackIndicatorView setState:NAKPlaybackIndicatorViewStatePlaying];
                break;

            default:
                [_playbackIndicatorView setState:NAKPlaybackIndicatorViewStatePaused];
                break;
        }
    }else{
        [_numberLabel setHidden:NO];
        [_playbackIndicatorView setState:NAKPlaybackIndicatorViewStateStopped];
    }
    [self setNeedsDisplay];
}

- (UITableViewCellSelectionStyle)selectionStyle{
    return UITableViewCellSelectionStyleBlue;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];

    if (animated && selected) {

        UIImage *image = [self imageWithCurrentView];

        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [imageView setImage:image];
        [imageView.layer setShadowOffset:CGSizeMake(4, 6)];
        [imageView.layer setShadowOpacity:1];
        [imageView.layer setShadowColor:UIColor.darkGrayColor.CGColor];

        [self.contentView addSubview:imageView];

        __block CGRect frame = self.bounds;
        frame.origin.y -= 8;
        frame.origin.x += 8;

        [UIView animateWithDuration:0.2 animations:^{
            //禁用, 防止多次触发
            [self setUserInteractionEnabled:NO];
            [imageView setFrame:frame];
        } completion:^(BOOL finished) {
            if (finished) {
                frame.origin.x = CGRectGetMaxX([UIScreen mainScreen].bounds);
                [UIView animateWithDuration:0.8 animations:^{
                    [imageView setFrame:frame];
                } completion:^(BOOL finished) {
                    [self setUserInteractionEnabled:YES];
                    [imageView removeFromSuperview];
                }];
            }
        }];
    }
}

@end
