//
//  BrowseSectionHeaderView.m
//  MMusic
//
//  Created by Magician on 2018/4/30.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <Masonry.h>

#import "BrowseSectionHeaderView.h"

@implementation BrowseSectionHeaderView
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _titleLable = UILabel.new;
        [_titleLable setFont:[UIFont systemFontOfSize:22]];
        [_titleLable setAdjustsFontSizeToFitWidth:YES];

        _moreButton = [[VBFPopFlatButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30) buttonType:buttonForwardType buttonStyle:buttonPlainStyle animateToInitialState:YES];
        [self addSubview:_titleLable];
        [self addSubview:_moreButton];
    }
    return self;
}
-(void)drawRect:(CGRect)rect{
    self.backgroundColor = UIColor.whiteColor;

    __weak typeof(self) weakSelf = self;
    [self.titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.mas_top);
        make.left.mas_equalTo(weakSelf.mas_left);
        make.bottom.mas_equalTo(weakSelf.mas_bottom);
    }];



    [self.moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat top = (CGRectGetHeight(weakSelf.bounds)-30)/2;

        UIEdgeInsets padding = UIEdgeInsetsMake(top, top, top, 1);
        make.top.mas_equalTo(weakSelf.mas_top).offset(padding.top);
        make.left.mas_equalTo(weakSelf.titleLable.mas_right).offset(padding.left);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    self.moreButton.tintColor = UIColor.blueColor;

}
@end
