//
//  MMDetailHeadView.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/12/31.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <Masonry.h>
#import "MMDetailHeadView.h"

@implementation MMDetailHeadView


- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _label = [[UILabel alloc] init];
        _imageView = [[UIImageView alloc] init];

        [_label setTextColor:MainColor];
        [_label setTextAlignment:NSTextAlignmentCenter];

        [self addSubview:_label];
        [self addSubview:_imageView];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];

    __weak typeof(self) weakSelf = self;
    // 约束
    [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf).offset(8);
        make.centerX.mas_equalTo(weakSelf);
        make.size.mas_equalTo(CGSizeMake(200, 200));
    }];

    [self.label mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.imageView.mas_bottom);
        make.left.right.mas_equalTo(weakSelf);
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
