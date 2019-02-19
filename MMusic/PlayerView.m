//
//  PlayerView.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/5.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "PlayerView.h"
#import "PlayProgressView.h"
#import "MMHeartSwitch.h"
#import "MMPlayerButton.h"

#import <Masonry.h>

@implementation PlayerView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {

        _imageView = [UIImageView new];
        _playProgressView  = [PlayProgressView new];
        _nameLabel = [UILabel new];
        _artistLabel = [UILabel new];
        _previous = [MMPlayerButton playerButtonWithStyle:MMPlayerButtonPreviousStyle];
        _play = [MMPlayerButton playerButtonWithStyle:MMPlayerButtonPlayStyle];
        _next = [MMPlayerButton playerButtonWithStyle:MMPlayerButtonNextStyle];
         _heartSwitch = [MMHeartSwitch new];
        _shareButton = [UIButton new];


        [_shareButton setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
        [_shareButton setBackgroundColor:[UIColor colorWithWhite:1 alpha:0]];

        //初始化偏移心型开关 避免出现在左上角
        [_heartSwitch setFrame:CGRectMake(-100, 100, 44, 44)];
        [_playProgressView setFrame:CGRectMake(-100, 100, 44, 44)];

        [self addSubview:_imageView];
        [self addSubview:_playProgressView];
        [self addSubview:_nameLabel];
        [self addSubview:_artistLabel];
        [self addSubview:_previous];
        [self addSubview:_play];
        [self addSubview:_next];
        [self addSubview:_heartSwitch];
        [self addSubview:_shareButton];

        [_imageView setBackgroundColor:[UIColor colorWithWhite:0.96 alpha:1]];

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
    [_nameLabel setTextAlignment:NSTextAlignmentLeft];
    [_artistLabel setTextAlignment:NSTextAlignmentLeft];
    [_previous setHidden:YES];

    UIEdgeInsets padding = UIEdgeInsetsMake(4, 4, 4, 4);
    __weak typeof(self) weakSelf = self;
    CGFloat itemW = CGRectGetHeight(weakSelf.bounds) - (padding.top*2);

    [_imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.mas_equalTo(weakSelf).insets(padding);
        make.width.mas_equalTo(itemW);
    }];

    [_next mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.mas_equalTo(weakSelf).insets(padding);
        CGFloat w = CGRectGetHeight(weakSelf.bounds)-(padding.top+padding.bottom);
        make.width.mas_equalTo(w);
    }];
    [_play mas_remakeConstraints:^(MASConstraintMaker *make) {
        CGFloat h = CGRectGetHeight(weakSelf.bounds)-(padding.top+padding.bottom)*2;
        CGFloat w = h;
        make.right.mas_equalTo(weakSelf.next.mas_left);//.inset(padding.right);
        make.centerY.mas_equalTo(weakSelf);
        make.size.mas_equalTo(CGSizeMake(w, h));
    }];

    [_nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.imageView.mas_right).offset(padding.left);
        make.top.mas_equalTo(weakSelf).offset(padding.top);
        make.right.mas_equalTo(weakSelf.play.mas_left).offset(padding.right);
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
    [_nameLabel setTextAlignment:NSTextAlignmentCenter];
    [_artistLabel setTextAlignment:NSTextAlignmentCenter];
    [_previous setHidden:NO];

    //边距
    UIEdgeInsets padding = UIEdgeInsetsMake(40, 20, 20, 20);
    __weak typeof(self) weakSelf = self;

    //消除布局冲突警告
    [_play mas_remakeConstraints:^(MASConstraintMaker *make) {
        [make removeExisting];
    }];
    [_next mas_remakeConstraints:^(MASConstraintMaker *make) {
        [make removeExisting];
    }];

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

    //播放按钮
    CGFloat h = 50;
    CGFloat w = h;
    CGSize size = CGSizeMake(w, h);

    CGFloat centerX = CGRectGetMidX(self.bounds);
    // masonry center 布局参照父视图center与给定CGPoint计算偏移
    CGFloat x1 = -(centerX/2); // centerX 左边
    CGFloat x2 = 0;
    CGFloat x3 = centerX/2;     //centerX右边

    //布局中间的按钮, 然后参照这个按钮 布局两边的两个
    [_play mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.artistLabel.mas_bottom).offset(padding.top);
        make.centerX.mas_equalTo(x2);
        make.size.mas_equalTo(size);
    }];
    [_previous mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.play);
        make.centerX.mas_equalTo(x1);
        make.size.mas_equalTo(size);
    }];
    [_next mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.play);
        make.centerX.mas_equalTo(x3);
        make.size.mas_equalTo(size);
    }];

    CGFloat heartW = 30.0f;
    [_heartSwitch mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.play.mas_bottom).offset(padding.top/2);
        make.size.mas_equalTo(CGSizeMake(heartW, heartW));
        make.centerX.mas_equalTo(weakSelf);
    }];

    [_shareButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.heartSwitch);
        make.left.mas_equalTo(weakSelf.heartSwitch.mas_right).inset(padding.left*3);
        make.size.mas_equalTo(weakSelf.heartSwitch);
    }];
}

@end
