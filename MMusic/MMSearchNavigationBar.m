//
//  MMSearchNavigationBar.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/24.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <Masonry.h>
#import "MMSearchNavigationBar.h"

@implementation MMSearchNavigationBar

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)layoutSubviews{
    for (UIView *subView in self.subviews) {
        [subView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(self);
        }];
    }

    [super layoutSubviews];
}

@end
