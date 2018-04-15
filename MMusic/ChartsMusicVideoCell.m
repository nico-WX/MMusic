//
//  MusicVideoCell.m
//  MMusic
//
//  Created by Magician on 2018/4/6.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import "ChartsMusicVideoCell.h"
#import <Masonry.h>

@implementation ChartsMusicVideoCell
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        CGFloat corner = 8.0f;
        self.layer.cornerRadius = corner;
        self.layer.masksToBounds = YES;

        self.titleLabel = UILabel.new;
        self.titleLabel.font = [UIFont systemFontOfSize:22];
        self.artistLabel = UILabel.new;
        self.artistLabel.textColor = UIColor.darkGrayColor;

        self.artworkView =  UIImageView.new;
//        self.artworkView.layer.cornerRadius = corner;
//        self.artworkView.layer.masksToBounds = YES;

        [self.contentView addSubview:self.artworkView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.artistLabel];
    }
    return self;
}

-(void)layoutSubviews{
    //artwork  16:9?
    CGFloat artH = CGRectGetWidth(self.contentView.bounds)*0.6;

    //artwork
    UIView *superview = self.contentView;
    [self.artworkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(superview.mas_top);
        make.left.equalTo(superview.mas_left);
        make.right.equalTo(superview.mas_right);
        make.height.equalTo(@(artH));
    }];

    UIEdgeInsets padding = UIEdgeInsetsMake(2, 5, 2, 2);
    //title
    CGFloat titleH = (CGRectGetHeight(self.contentView.bounds) -artH)/2;
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.artworkView.mas_bottom);
        make.left.equalTo(superview.mas_left).with.offset(padding.left);
        make.right.equalTo(superview.mas_right);
        make.height.mas_equalTo(titleH);
    }];

    //artist
    [self.artistLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom);
        make.left.equalTo(superview.mas_left).with.offset(padding.left);
        make.right.equalTo(superview.mas_right);
        make.height.mas_equalTo(titleH);
    }];

}
@end
