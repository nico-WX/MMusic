//
//  MyCell.m
//  蒙版Cell
//
//  Created by 🐙怪兽 on 2018/11/1.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import "MyCell.h"

@interface MyCell ()

@property(nonatomic, strong) UIVisualEffectView *visEffView;
@end

@implementation MyCell

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {

        _titleLabel = [[UILabel alloc] init];
        _imageView = [[UIImageView alloc] init];


        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        _visEffView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];

        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_titleLabel setFont:[UIFont systemFontOfSize:28]];

        [self.contentView addSubview:_imageView];
        [self.contentView addSubview:_visEffView];
        [self.contentView addSubview:_titleLabel];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];

    [_imageView setFrame:self.bounds];

    CGFloat h = 44.0f;
    CGFloat y = CGRectGetMaxY(self.bounds) - h;
    CGFloat w = CGRectGetWidth(self.bounds);
    CGRect titleFrame = CGRectMake(0, y, w, h);

    [_titleLabel setFrame:titleFrame];
    [_visEffView setFrame:titleFrame];
}

@end
