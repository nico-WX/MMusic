//
//  ScreeningCell.m
//  MMusic
//
//  Created by Magician on 2018/5/4.
//  Copyright © 2018年 com.😈. All rights reserved.
//
#import <Masonry.h>
#import "ScreeningCell.h"

@implementation ScreeningCell
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _nameLable = UILabel.new;
        [_nameLable setTextAlignment:NSTextAlignmentCenter];
        [_nameLable setAdjustsFontSizeToFitWidth:YES];
        [self.contentView addSubview:_nameLable];
        [self setBackgroundColor:[UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1]];

        UIView *bgView = UIView.new;
        bgView.backgroundColor = UIColor.grayColor;
        [self setSelectedBackgroundView:bgView];
    }
    return self;
}
-(void)drawRect:(CGRect)rect{
    [self setBackgroundColor:[UIColor whiteColor]];
    UIView *superview = self.contentView;
    [self.nameLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(superview);
    }];
}
@end
