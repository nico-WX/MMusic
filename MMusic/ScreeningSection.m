//
//  ScreeningHeader.m
//  MMusic
//
//  Created by Magician on 2018/5/4.
//  Copyright © 2018年 com.😈. All rights reserved.
//
#import <Masonry.h>
#import "ScreeningSection.h"

@implementation ScreeningSection
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _titleLabel = UILabel.new;
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_titleLabel setAdjustsFontSizeToFitWidth:YES];
        [_titleLabel setTextColor:UIColor.grayColor];
        [self addSubview:_titleLabel];
        [self setBackgroundColor:UIColor.whiteColor];
    }
    return self;
}

-(void)drawRect:(CGRect)rect{
    UIView *superview = self;
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superview.mas_top);
        make.left.mas_equalTo(superview.mas_left).offset(0);
        make.bottom.mas_equalTo(superview.mas_bottom);
        make.width.mas_equalTo(100);
    }];
}
@end
