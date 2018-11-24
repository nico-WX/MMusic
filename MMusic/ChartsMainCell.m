//
//  ChartsMainCell.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/10/25.
//  Copyright © 2018年 com.😈. All rights reserved.
//
#import <Masonry.h>

#import "ChartsMainCell.h"


@interface ChartsMainCell()

@end

@implementation ChartsMainCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self =[super initWithFrame:frame]) {

        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setFont:[UIFont systemFontOfSize:28.0]];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_titleLabel setTextColor:UIColor.whiteColor];
        //[_titleLabel setTextColor:MainColor];
        [self setBackgroundColor:[self randomColor]];

        [self.contentView addSubview:_titleLabel];

//        [self.layer setShadowOffset:CGSizeMake(5, 10)];
//        [self.layer setShadowOpacity:0.7];
//        [self.layer setShadowColor:UIColor.grayColor.CGColor];
    }
    return self;
}
-(void)prepareForReuse{

    [super prepareForReuse];
}

- (void)layoutSubviews{

    UIView *superView = self.contentView;
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superView).mas_offset(8);
        make.left.right.mas_equalTo(superView);
    }];

    [super layoutSubviews];
}

- (UIColor*)randomColor{
    int max = 256.0;  // 0-255
    int red     = (arc4random()%max);
    int green   = arc4random()%max;
    int blue    = arc4random()%max;

    max -= 1;   // 255
    CGFloat r = ((float)red)/max;
    CGFloat g = ((float)green)/max;
    CGFloat b = ((float)blue)/max;

    CGFloat alpha   = 1.0; //((float)(arc4random()%256))/255.0;

    return [UIColor colorWithRed:r green:g blue:b alpha:alpha];
}

@end
