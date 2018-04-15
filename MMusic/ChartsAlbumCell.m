//
//  ChartsCell.m
//  MMusic
//
//  Created by Magician on 2018/4/3.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import "ChartsAlbumCell.h"
#import <Masonry.h>

@implementation ChartsAlbumCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
        //self.backgroundColor = UIColor.whiteColor;
        //self.contentView.backgroundColor = UIColor.whiteColor;
        CGFloat corner = 8.0f;
        self.layer.cornerRadius = corner;
        self.layer.masksToBounds = YES;

        self.titleLabel = UILabel.new;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.layer.cornerRadius = corner;
        self.titleLabel.layer.masksToBounds = YES;

        self.artworkView = UIImageView.new;
//        self.artworkView.layer.cornerRadius = corner;
//        self.artworkView.layer.masksToBounds = YES;

        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.artworkView];
    }
    return self;
}

- (void)layoutSubviews{

    //图片高度  等于宽度,  形成正方形
    CGFloat artworkH = CGRectGetWidth(self.bounds);
    //layout
    UIView *superview = self.contentView;
    [self.artworkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(superview.mas_top);
        make.left.equalTo(superview.mas_left);
        make.right.equalTo(superview.mas_right);
        make.height.equalTo(@(artworkH));
    }];

    __weak typeof(self) weakSelf = self;
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.artworkView.mas_bottom);
        make.left.equalTo(superview.mas_left);
        make.right.equalTo(superview.mas_right);
        make.bottom.equalTo(superview.mas_bottom);
    }];
}

@end
