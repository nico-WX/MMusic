//
//  ChartCell.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/10/25.
//  Copyright © 2018年 com.😈. All rights reserved.
//
#import <Masonry.h>

#import "ChartCell.h"
#import "Chart.h"
#import "ChartsSubViewController.h"

@interface ChartCell()
@property(nonatomic, strong) ChartsSubViewController *chartsViewController;
@property(nonatomic, strong) UILabel *titleLabel;

@end

@implementation ChartCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self =[super initWithFrame:frame]) {

        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setFont:[UIFont systemFontOfSize:22.0]];
        [_titleLabel setTextColor:MainColor];
        _chartsViewController = [[ChartsSubViewController alloc] init];

        [self.contentView addSubview:_titleLabel];
        [self.contentView addSubview:_chartsViewController.view];


        [self.layer setShadowOffset:CGSizeMake(5, 10)];
        [self.layer setShadowOpacity:0.7];
        [self.layer setShadowColor:UIColor.grayColor.CGColor];

    }
    return self;
}

- (void)layoutSubviews{

    UIView *superView = self.contentView;
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superView.mas_top);
        make.left.mas_equalTo(superView.mas_left).offset(10);
        make.right.mas_equalTo(superView.mas_right);
    }];

    __weak typeof(self) weakSelf = self;
    [_chartsViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.titleLabel.mas_bottom);
        make.left.mas_equalTo(superView.mas_left);
        make.right.mas_equalTo(superView.mas_right);
        make.bottom.mas_equalTo(superView.mas_bottom);
    }];


    [super layoutSubviews];
}
- (void)setChart:(Chart *)chart{
    if (_chart != chart) {
        _chart = chart;

        _titleLabel.text = chart.name;
        _chartsViewController.chart = chart;
    }
}
- (void)setNavigationController:(UINavigationController *)navigationController{
    if (_chartsViewController) {
        //传递导航控制器,
        _chartsViewController.mainNavigatonController = navigationController;
    }
}

@end
