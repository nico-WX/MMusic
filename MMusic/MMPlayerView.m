//
//  MMPlayerView.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/5.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "MMPlayerView.h"
#import "PlayProgressView.h"
#import "MMPlayerControlButtonView.h"
#import "MMHeartSwitch.h"
#import "MMPlayerButton.h"

#import <Masonry.h>

@interface MMPlayerView ()
@property(nonatomic, strong) MMPlayerControlButtonView *playerButtonView;
@end

@implementation MMPlayerView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _imageView = [UIImageView new];
        _playProgressView  = [PlayProgressView new];
        _playerButtonView = [MMPlayerControlButtonView new];
        _nameLabel = [UILabel new];
        _artistLabel = [UILabel new];
        _heartSwitch = [MMHeartSwitch new];

        _previous = _playerButtonView.previous;
        _play = _playerButtonView.play;
        _next = _playerButtonView.next;

        [self addSubview:_imageView];
        [self addSubview:_playProgressView];
        [self addSubview:_nameLabel];
        [self addSubview:_artistLabel];
        [self addSubview:_playerButtonView];
        [self addSubview:_heartSwitch];

        [_imageView setBackgroundColor:[UIColor colorWithWhite:0.95 alpha:1]];

        //text
        // Llabel 文本 setter
        [_nameLabel setAdjustsFontSizeToFitWidth:YES];
        [_nameLabel setTextColor:MainColor];
        [_nameLabel setFont:[UIFont systemFontOfSize:[UIFont buttonFontSize]]];

        [_artistLabel setTextColor:UIColor.grayColor];
        [_artistLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
        [_artistLabel setAdjustsFontSizeToFitWidth:YES];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];

    if (CGRectGetHeight(self.bounds) < 100) {
        [self popStateLayout];
    }else{
        [self poppingStateLayout];
    }
}


#pragma mark - help method
// 窗口缩放在视图下部时
- (void)popStateLayout{
    //更改文本对齐
    [self.nameLabel setTextAlignment:NSTextAlignmentLeft];
    [self.artistLabel setTextAlignment:NSTextAlignmentLeft];
    [self.previous setHidden:YES];


    UIEdgeInsets padding = UIEdgeInsetsMake(4, 4, 4, 4);
    __weak typeof(self) weakSelf = self;
    CGFloat itemW = CGRectGetHeight(weakSelf.bounds) - (padding.top*2);

    [_imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.mas_equalTo(weakSelf).insets(padding);
        make.width.mas_equalTo(itemW);
    }];

    [_playerButtonView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.mas_equalTo(weakSelf).insets(padding);
        make.width.mas_equalTo(itemW*2);
    }];

    [_nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.imageView.mas_right).offset(padding.left);
        make.right.mas_equalTo(weakSelf.playerButtonView.mas_left).offset(-padding.right);
        make.bottom.mas_equalTo(weakSelf).offset(-CGRectGetMidY(weakSelf.bounds));
        make.top.mas_lessThanOrEqualTo(weakSelf).offset(padding.top);
    }];

    [_artistLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.nameLabel.mas_bottom);
        make.left.right.mas_equalTo(weakSelf.nameLabel);
        make.bottom.mas_lessThanOrEqualTo(weakSelf).inset(padding.bottom);
    }];
}

// 视图全部打开状态
- (void)poppingStateLayout{
    //更改文本对齐
    [self.nameLabel setTextAlignment:NSTextAlignmentCenter];
    [self.artistLabel setTextAlignment:NSTextAlignmentCenter];
    [self.previous setHidden:NO];

    //边距
    UIEdgeInsets padding = UIEdgeInsetsMake(40, 20, 20, 20);
    __weak typeof(self) weakSelf = self;

    //重新布局
    [_imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(weakSelf).insets(padding);
        CGFloat h = CGRectGetWidth(weakSelf.frame) - (padding.left+padding.right);
        make.height.mas_equalTo(h);
    }];

    [_playProgressView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.imageView.mas_bottom).offset(padding.top/3);
        make.left.right.mas_equalTo(weakSelf).insets(padding);
        make.height.mas_equalTo(40);
    }];

    [_nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.playProgressView.mas_bottom).offset(padding.top/3);
        make.left.right.mas_equalTo(weakSelf).insets(padding);
    }];
    [_artistLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.nameLabel.mas_bottom).offset(10);
        make.left.right.mas_equalTo(weakSelf).insets(padding);
    }];

    [_playerButtonView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(weakSelf).insets(padding);
        make.top.mas_equalTo(weakSelf.artistLabel.mas_bottom).offset(padding.top);
        make.height.mas_equalTo(50);
    }];

    CGFloat heartW = 30.0f;
    CGFloat x = CGRectGetMidX(self.bounds) - heartW/2;
    [self.heartSwitch mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.playerButtonView.mas_bottom).offset(padding.top/2);
        make.size.mas_equalTo(CGSizeMake(heartW, heartW));
        make.left.mas_equalTo(x);
    }];
}



@end
