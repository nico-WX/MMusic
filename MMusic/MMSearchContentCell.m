//
//  MMSearchContentCell.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/25.
//  Copyright © 2018 com.😈. All rights reserved.
//
#import <Masonry.h>

#import "MMSearchContentCell.h"
#import "Resource.h"

@implementation MMSearchContentCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _imageView = [[UIImageView alloc] init];
        _titleLabel = [[UILabel alloc] init];
        _subTitleLabel = [[UILabel alloc] init];

        [self.contentView addSubview:_imageView];
        [self.contentView addSubview:_titleLabel];
        [self.contentView addSubview:_subTitleLabel];
    }
    return self;
}

- (void)setResource:(Resource *)resource{
    if (_resource != resource) {
        _resource = resource;

        [_titleLabel setText:[resource valueForKeyPath:@"attributes.name"]];

    }
}

- (void)layoutSubviews{
    UIEdgeInsets padding = UIEdgeInsetsMake(4, 4, 4, 4);

    UIView *superView = self.contentView;
    __weak typeof(self) weakSelf = self;
    [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.mas_equalTo(superView).insets(padding);

        CGFloat w = CGRectGetHeight(superView.bounds)-(padding.top+padding.bottom);
        make.width.mas_equalTo(w);
    }];

    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.imageView.mas_right).offset(padding.left);
        make.top.mas_equalTo(weakSelf.imageView.mas_top);
        make.right.mas_equalTo(superView).mas_offset(-padding.right);
    }];

    [self.subTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.titleLabel.mas_bottom);
        make.left.mas_equalTo(weakSelf.titleLabel.mas_left);
        make.bottom.mas_lessThanOrEqualTo(superView.mas_bottom).offset(-padding.bottom);
        make.right.mas_equalTo(superView.mas_right).offset(-padding.right);
    }];


    [super layoutSubviews];
}

@end
