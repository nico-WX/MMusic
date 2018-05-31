//
//  HeaderView.m
//  MMusic
//
//  Created by Magician on 2018/3/10.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import "DetailHeaderView.h"
#import <Masonry.h>

@implementation DetailHeaderView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.artworkView = UIImageView.new;
        self.nameLabel = UILabel.new;
        self.desc = UITextView.new;
        [self addSubview:self.artworkView];
        [self addSubview:self.nameLabel];
        [self addSubview:self.desc];

        self.nameLabel.font = [UIFont systemFontOfSize:28.0];
        self.desc.textColor = UIColor.grayColor;
        self.desc.editable  = NO;

        UIColor *color = [UIColor colorWithRed:0.95 green:0.95 blue:0.98 alpha:0.98];
        self.artworkView.backgroundColor = color;
        self.nameLabel.backgroundColor = color;
        self.desc.backgroundColor = color;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    [self setBackgroundColor:UIColor.whiteColor];
    __weak typeof(self) weakSelf = self;
    UIEdgeInsets padding = UIEdgeInsetsMake(5, 5, 5, 5);
    [self.artworkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.mas_top).with.offset(padding.top);
        make.left.mas_equalTo(weakSelf.mas_left).with.offset(padding.left);
        make.bottom.mas_equalTo(weakSelf.mas_bottom).with.offset(-padding.bottom);
        make.width.equalTo(weakSelf.mas_height).with.offset(-padding.top*2);
    }];

    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.mas_top).with.offset(padding.top);
        make.left.mas_equalTo(weakSelf.artworkView.mas_right).with.offset(padding.left);
        make.right.mas_equalTo(weakSelf.mas_right).with.offset(-padding.right);
        make.height.mas_equalTo(44);
    }];

    [self.desc mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.nameLabel.mas_bottom).with.offset(padding.top);
        make.left.mas_equalTo(weakSelf.artworkView.mas_right).with.offset(padding.left);
        make.right.mas_equalTo(weakSelf.mas_right).with.offset(-padding.right);
        make.bottom.mas_equalTo(weakSelf.mas_bottom).with.offset(-padding.bottom);
    }];
}


@end
