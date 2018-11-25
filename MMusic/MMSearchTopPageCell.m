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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame{
    if (self =[super initWithFrame:frame]) {
        _titleLabel = [[UILabel alloc] initWithFrame:frame];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_titleLabel setAdjustsFontSizeToFitWidth:YES];
        [self.contentView addSubview:_titleLabel];
    }
    return self;
}
- (void)layoutSubviews{
    [_titleLabel setFrame:self.contentView.bounds];
    [super layoutSubviews];
}

@end
