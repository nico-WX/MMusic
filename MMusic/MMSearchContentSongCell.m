//
//  MMSearchContentSongCell.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/25.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <Masonry.h>
#import <NAKPlaybackIndicatorView.h>
#import <MediaPlayer/MediaPlayer.h>

#import "MMSearchContentSongCell.h"
#import "Resource.h"
#import "UIView+LayerImage.h"

@interface MMSearchContentSongCell ()
@property(nonatomic, strong) UILabel *durationLabel;
@property(nonatomic, strong) NAKPlaybackIndicatorView *stateView;
@end

@implementation MMSearchContentSongCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _durationLabel = [[UILabel alloc] init];
        [_durationLabel setTextColor:UIColor.darkTextColor];
        [_durationLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
        [_durationLabel setTextAlignment:NSTextAlignmentCenter];


        NAKPlaybackIndicatorViewStyle *style = [NAKPlaybackIndicatorViewStyle iOS10Style];
        _stateView = [[NAKPlaybackIndicatorView alloc] initWithStyle:style];
        [_stateView setHidesWhenStopped:YES];

        [self.contentView addSubview:_stateView];
        [self.contentView addSubview:_durationLabel];


        [[NSNotificationCenter defaultCenter] addObserverForName:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            [self updateState];
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            [self updateState];
        }];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];

    UIView *superView = self.contentView;
    [self.durationLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.mas_equalTo(superView).insets(UIEdgeInsetsMake(4, 4, 4, 4));
        CGFloat w = CGRectGetHeight(superView.bounds)-8;
        make.width.mas_equalTo(w*1.2);
    }];

    __weak typeof(self) weakSelf = self;
    [self.stateView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf.imageView);
    }];
}


// 选中s动画
- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];

    if (selected ) {
        UIImage *image = [self imageWithCurrentView]; // 切角了, 但是为什么渲染到上下文中, 切角还是有
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        [imageView setImage:image];

        // 切角相同
        [imageView.layer setCornerRadius:self.layer.cornerRadius];
        [imageView.layer setMasksToBounds:self.layer.masksToBounds];

        [self.contentView addSubview:imageView];

        CGRect firstSetp = imageView.frame;
        firstSetp.origin.y += 10;
        CGRect endFrame = imageView.frame;
        endFrame.origin.y = CGRectGetHeight([UIScreen mainScreen].bounds);

        [UIView animateWithDuration:0.5 animations:^{
            //暂时禁用交互
            [self setUserInteractionEnabled:NO];
            [imageView setFrame:firstSetp];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3 animations:^{
                [imageView setFrame:endFrame];
            } completion:^(BOOL finished) {
                [self setUserInteractionEnabled:YES];
                [imageView removeFromSuperview];
            }];
        }];
    }
}


- (void)setResource:(Resource *)resource{
    if (resource == self.resource) {
        return;
    }

    [super setResource:resource];
    NSString *text = [resource.attributes valueForKey:@"durationInMillis"];
    NSInteger duration = [text integerValue]/1000; //秒

    NSString *str = [NSString stringWithFormat:@"%.02d:%.02d",(int)(duration/60),(int)(duration%60)];
    [_durationLabel setText:str];

    [self updateState];
}

- (void)updateState{

    NSString *identifier = self.resource.identifier;
    if (![identifier isEqualToString:MainPlayer.nowPlayingItem.playbackStoreID]) {
        [UIView animateWithDuration:0.5 animations:^{
//            [self.imageView setHidden:NO];
//            [self.stateView setHidden:YES];
            [self.imageView setAlpha:1];
            [self.stateView setAlpha:0];
        }];
        return;
    }

    [UIView animateWithDuration:0.5 animations:^{
        [self.stateView setAlpha:1];
        [self.imageView setAlpha:0];
//        [self.stateView setHidden:NO];
//        [self.imageView setHidden:YES];
    }];

    switch (MainPlayer.playbackState) {
        case MPMusicPlaybackStateInterrupted:
        case MPMusicPlaybackStatePaused:
            [self.stateView setState:NAKPlaybackIndicatorViewStatePaused];
            break;
        case MPMusicPlaybackStateStopped:
            [self.stateView setState:NAKPlaybackIndicatorViewStateStopped];
            break;

        default:
            [self.stateView setState:NAKPlaybackIndicatorViewStatePlaying];
            break;
    }
    [self setNeedsDisplay];
}

@end
