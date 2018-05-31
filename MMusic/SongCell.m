//
//  SongCell.m
//  MMusic
//
//  Created by Magician on 2018/3/11.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <NAKPlaybackIndicatorView.h>
#import <Masonry.h>
#import "SongCell.h"
#import "Song.h"

@interface SongCell()
@property(nonatomic, readonly) NAKPlaybackIndicatorView *playbackIndicatorView;
@property(nonatomic, readonly) UILabel *nameLabel;
@property(nonatomic, readonly) UILabel *artistLabel;
@property(nonatomic, readonly) UILabel *durationLabel;
@end

@implementation SongCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {

        NAKPlaybackIndicatorViewStyle *viewStyle = [NAKPlaybackIndicatorViewStyle iOS10Style];
        _playbackIndicatorView = [[NAKPlaybackIndicatorView alloc] initWithStyle:viewStyle];
        [_playbackIndicatorView setTintColor:MainColor];

        _numberLabel = ({
            UILabel *label = UILabel.new;
            [label setTextAlignment:NSTextAlignmentCenter];
            [label setFont:[UIFont boldSystemFontOfSize:16]];

            label;
        });

        _nameLabel = ({
            UILabel *lable = UILabel.new;
            [lable setAdjustsFontSizeToFitWidth:YES];

            lable;
        });

        _artistLabel = ({
            UILabel *label = UILabel.new;
            [label setFont:[UIFont systemFontOfSize:12]];
            [label setTextColor:[UIColor grayColor]];

            label;
        });

        _durationLabel = ({
            UILabel *label = UILabel.new;
            [label setTextAlignment:NSTextAlignmentCenter];
            [label setFont:[UIFont italicSystemFontOfSize:12]];

            label;
        });

        [self.contentView addSubview:_playbackIndicatorView];
        [self.contentView addSubview:_numberLabel];
        [self.contentView addSubview:_nameLabel];
        [self.contentView addSubview:_artistLabel];
        [self.contentView addSubview:_durationLabel];

        [self setNeedsUpdateConstraints];
    }
    return self;
}

-(void)prepareForReuse{
    [super prepareForReuse];
    _numberLabel.text = nil;
    _nameLabel.text = nil;
    _artistLabel.text = nil;
    _durationLabel.text = nil;
    self.state = NAKPlaybackIndicatorViewStateStopped;
}

- (void)setNeedsUpdateConstraints{
    
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

    [super setNeedsUpdateConstraints];
}

#pragma mark - setter
-(void)setSong:(Song *)song{
    _song = song;

    //设置歌曲信息
    self.nameLabel.text = self.song.name;
    self.artistLabel.text = self.song.artistName;
    NSTimeInterval duration = self.song.durationInMillis.doubleValue / 1000.0;
    NSString *durationText = [NSString stringWithFormat:@"%d:%02d",(int32_t)duration/60,(int32_t)duration%60];
    self.durationLabel.text = durationText;
}
-(void)setState:(NAKPlaybackIndicatorViewState)state{
    [self.playbackIndicatorView setState:state];
    [self.numberLabel setHidden:(state != NAKPlaybackIndicatorViewStateStopped)];
}

#pragma mark - getter
-(NAKPlaybackIndicatorViewState)state{
    return self.playbackIndicatorView.state;
}
@end
