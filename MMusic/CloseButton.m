//
//  CloseButton.m
//  ScrollPage
//
//  Created by 🐙怪兽 on 2018/12/1.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <Masonry.h>
#import "CloseButton.h"

@interface CloseButton ()

@property(nonatomic, strong)UIVisualEffectView *effectView;

@property(nonatomic, strong)UIView *line1;
@property(nonatomic, strong)UIView *line2;
@end

@implementation CloseButton

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

    CGFloat h = 3.0f;
    __weak typeof(self) weakSelf = self;
    UIView *superView = self.effectView.contentView;

    [_effectView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf);
    }];

    //两条线重叠
    [_line1 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(superView);
        make.left.right.mas_equalTo(superView).insets(UIEdgeInsetsMake(0, 4, 0, 4));
        make.height.mas_equalTo(h);
    }];
    [_line2 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf.line1);
    }];

    // 转角度
    [_line1 setTransform:CGAffineTransformMakeRotation(-M_PI_4)];
    [_line2 setTransform:CGAffineTransformMakeRotation(M_PI_4)];

    //圆角
    CGFloat radius = h/2;

    _line1.layer.cornerRadius = radius;
    _line2.layer.cornerRadius = radius;

    _line1.layer.masksToBounds = YES;
    _line2.layer.masksToBounds = YES;
}


@end
