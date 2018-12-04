//
//  MMCloseButton.m
//  ScrollPage
//
//  Created by 🐙怪兽 on 2018/12/1.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <Masonry.h>
#import "MMCloseButton.h"


@interface MMCloseButton ()
@property(nonatomic, strong)UIVisualEffectView *effectView;

@property(nonatomic, strong)UIView *line1;
@property(nonatomic, strong)UIView *line2;
@end

@implementation MMCloseButton

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {

        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        _effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        _line1 = [[UIView alloc] initWithFrame:CGRectZero];
        _line2 = [[UIView alloc] initWithFrame:CGRectZero];

        [_line1 setUserInteractionEnabled:NO];
        [_line2 setUserInteractionEnabled:NO];
        [_effectView setUserInteractionEnabled:NO];

        UIColor *color = [UIColor colorWithWhite:0 alpha:1];
        [_line1 setBackgroundColor:color];
        [_line2 setBackgroundColor:color];

        [self addSubview:_effectView];
        [_effectView.contentView addSubview:_line1];
        [_effectView.contentView addSubview:_line2];
    }
    return self;
}


- (void)layoutSubviews{
    [super layoutSubviews];

    [self.layer setCornerRadius:CGRectGetHeight(self.bounds)/2];
    [self.layer setMasksToBounds:YES];


    CGFloat x = 4.0f;
    //CGFloat w = CGRectGetWidth(self.effectView.contentView.bounds) - x*2;
    CGFloat h = 3.0f;
    CGFloat y = CGRectGetMidY(self.effectView.contentView.bounds) - h/2;

    __weak typeof(self) weakSelf = self;
    UIView *superView = self.effectView.contentView;
    [self.effectView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf);
    }];

    [self.line1 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superView).offset(y);
        make.left.mas_equalTo(superView).offset(x);
        make.right.mas_equalTo(superView).offset(-x);
        make.height.mas_equalTo(h);
    }];

    [self.line2 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superView).offset(y);
        make.left.mas_equalTo(superView).offset(x);
        make.right.mas_equalTo(superView).offset(-x);
        make.height.mas_equalTo(h);
    }];


    // 转角度
    [_line1 setTransform:CGAffineTransformMakeRotation(-M_PI_4)];
    [_line2 setTransform:CGAffineTransformMakeRotation(M_PI_4)];

    //圆角
    [_line1.layer setCornerRadius:h/2];
    [_line1.layer setMasksToBounds:YES];
    [_line2.layer setCornerRadius:h/2];
    [_line2.layer setMasksToBounds:YES];
}


@end
