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

        _artworkView    = UIImageView.new;
        _nameLabel      = UILabel.new;
        _desc           = UITextView.new;

        _nameLabel.font = [UIFont systemFontOfSize:28.0];
        [_nameLabel setAdjustsFontSizeToFitWidth:YES];
        _desc.textColor = UIColor.grayColor;
        _desc.editable  = NO;

        UIColor *color = [UIColor colorWithRed:0.95 green:0.95 blue:0.98 alpha:0.98];
        [_artworkView setBackgroundColor:color];
        [_nameLabel setBackgroundColor:color];
        [_desc setBackgroundColor:color];

        [self setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0]];
        //add subView
        [self addSubview:_artworkView];
        [self addSubview:_nameLabel];
        [self addSubview:_desc];
    }
    return self;
}

- (void) layout{
    // Drawing code
    __weak typeof(self) weakSelf = self;
    UIEdgeInsets padding = UIEdgeInsetsMake(5, 5, 5, 5);
    [self.artworkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.mas_top).with.offset(padding.top);
        make.left.mas_equalTo(weakSelf.mas_left).with.offset(padding.left);
        make.width.height.mas_equalTo(@66.0);
    }];

    [self.artworkView.layer setCornerRadius:33.0];
    [self.artworkView.layer setMasksToBounds:YES];


    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.mas_top).with.offset(padding.top);
        make.left.mas_equalTo(weakSelf.artworkView.mas_right).with.offset(padding.left);
        make.right.mas_equalTo(weakSelf.mas_right).with.offset(-padding.right);
        //make.height.mas_equalTo(66);
    }];

    [self.desc mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.nameLabel.mas_bottom).with.offset(padding.top);
        make.left.mas_equalTo(weakSelf.artworkView.mas_right).with.offset(padding.left);
        make.right.mas_equalTo(weakSelf.mas_right).with.offset(-padding.right);
        make.bottom.mas_equalTo(weakSelf.mas_bottom).with.offset(-padding.bottom);
    }];
}


- (void)layoutSubviews{
    [self layout];

    [super layoutSubviews];
}

@end
