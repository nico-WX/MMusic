//
//  ChartsSongCell.m
//  MMusic
//
//  Created by Magician on 2018/4/24.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <Masonry.h>
#import "ChartsSongCell.h"


@implementation ChartsSongCell

-(void)drawRect:(CGRect)rect{
    self.artistLabel.font = [UIFont systemFontOfSize:12];
    self.artistLabel.textColor = UIColor.grayColor;
}
- (void)layoutSubviews{

    __weak typeof(self) weakSelf = self;
    UIEdgeInsets padding = UIEdgeInsetsMake(2, 2, 2, 2);
    UIView *superview = self.contentView;
    [self.artworkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superview.mas_top).with.offset(padding.top);
        make.left.mas_equalTo(superview.mas_left).with.offset(padding.left);
        make.bottom.mas_equalTo(superview.mas_bottom).with.offset(-padding.bottom);

        CGFloat w = CGRectGetHeight(superview.bounds) - (padding.top+padding.bottom);
        make.width.mas_equalTo(w);
    }];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superview.mas_top);
        make.left.mas_equalTo(weakSelf.artworkView.mas_right).with.offset(padding.left*3);
        make.right.mas_equalTo(superview).with.offset(-padding.right);
        CGFloat h = CGRectGetHeight(superview.bounds) *0.6;
        make.height.mas_equalTo(h);
    }];

    [self.artistLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.titleLabel.mas_bottom);
        make.left.mas_equalTo(weakSelf.artworkView.mas_right).with.offset(padding.left*3);
        make.right.mas_equalTo(superview.mas_right).with.offset(-padding.right);
        make.bottom.mas_equalTo(superview.mas_bottom).with.offset(padding.bottom);
    }];
}
@end
