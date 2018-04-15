//
//  SearchSectionView.m
//  MMusic
//
//  Created by Magician on 2018/4/10.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import "SearchSectionWaitingHeader.h"
#import <Masonry.h>

@implementation SearchSectionWaitingHeader

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code

    CGFloat titleW = CGRectGetWidth(self.bounds) *0.7;
    UIEdgeInsets padding = UIEdgeInsetsMake(0, 10, 0, 0);
    UIView *superview = self.contentView;
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superview.mas_top);
        make.left.mas_equalTo(superview.mas_left).with.offset(padding.left);
        make.bottom.mas_equalTo(superview.mas_bottom).with.offset(-padding.bottom);
        make.width.mas_equalTo(titleW);
    }];

}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        self.titleLabel = UILabel.new;
        [self.contentView addSubview:self.titleLabel];
    }
    return self;
}

@end
