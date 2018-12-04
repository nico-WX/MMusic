//
//  MMSearchTopPageCell.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/24.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <Masonry.h>
#import "MMSearchTopPageCell.h"

@implementation MMSearchTopPageCell


- (instancetype)initWithFrame:(CGRect)frame{
    if (self =[super initWithFrame:frame]) {
        _titleLabel = [[UILabel alloc] initWithFrame:frame];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_titleLabel setAdjustsFontSizeToFitWidth:YES];
        [_titleLabel setFont:[UIFont systemFontOfSize:[UIFont buttonFontSize]]];

        [self.contentView addSubview:_titleLabel];
    }
    return self;
}
- (void)layoutSubviews{
    [_titleLabel setFrame:self.contentView.bounds];
    [super layoutSubviews];
}
- (void)setSelected:(BOOL)selected{
    if (selected) {
        [_titleLabel setTextColor:MainColor];
    }else{
        [_titleLabel setTextColor:UIColor.blackColor];
    }
}

@end
