//
//  MMPlayerControlButtonView.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/5.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import <Masonry.h>
#import "MMPlayerControlButtonView.h"
#import "MMPlayerButton.h"

@implementation MMPlayerControlButtonView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _previous = [MMPlayerButton playerButtonWithStyle:MMPlayerButtonPreviousStyle];
        _play = [MMPlayerButton playerButtonWithStyle:MMPlayerButtonPlayStyle];
        _next = [MMPlayerButton playerButtonWithStyle:MMPlayerButtonNextStyle];

        [self addSubview:_previous];
        [self addSubview:_play];
        [self addSubview:_next];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];

    CGFloat w = CGRectGetWidth(self.bounds)/3;
    //CGFloat h = CGRectGetHeight(self.bounds);

    [_previous mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.mas_equalTo(self);
        make.width.mas_equalTo(w);
    }];
    [_play mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(self);
        make.left.mas_equalTo(self.previous.mas_right);
        make.width.mas_equalTo(w);
    }];

    [_next mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.mas_equalTo(self);
        make.width.mas_equalTo(w);
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
