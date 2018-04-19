//
//  ResultsSectionView.m
//  MMusic
//
//  Created by Magician on 2018/4/10.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import "ResultsSectionHeader.h"
#import <Masonry.h>

@implementation ResultsSectionHeader


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code

    UIEdgeInsets padding = UIEdgeInsetsMake(2, 8, 2, 8);
    __weak typeof(self) weakSelf = self;
    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.contentView.mas_top).with.offset(padding.top);
        make.left.mas_equalTo(weakSelf.contentView.mas_left).with.offset(padding.left);
        make.bottom.mas_equalTo(weakSelf.contentView.mas_bottom).with.offset(-padding.bottom);
        make.width.mas_equalTo(CGRectGetWidth(weakSelf.contentView.bounds)*0.5);
    }];

    [self.more mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.contentView.mas_top).with.offset(padding.top);
        make.right.mas_equalTo(weakSelf.contentView.mas_right).with.offset(-padding.right);
        make.bottom.mas_equalTo(weakSelf.contentView.mas_bottom).with.offset(-padding.bottom);
        make.width.mas_equalTo(CGRectGetHeight(weakSelf.contentView.bounds)-padding.top-padding.bottom);
    }];
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        self.title = UILabel.new;
        CGRect rect = CGRectMake(0, 0, 30, 30);
        self.more = [[VBFPopFlatButton alloc] initWithFrame:rect buttonType:buttonMinusType buttonStyle:buttonPlainStyle animateToInitialState:YES];

        self.more.tintColor = UIColor.grayColor;
        [self.contentView addSubview:self.title];
        [self.contentView addSubview:self.more];
    }
    return self;
}

@end
