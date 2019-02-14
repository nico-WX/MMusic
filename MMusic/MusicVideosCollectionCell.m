//
//  MusicVideosCollectionCell.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/18.
//  Copyright © 2019 com.😈. All rights reserved./Users/pan/Desktop/MyProject/MMusic/pwx/MMusic/MMusic
//

#import "MusicVideosCollectionCell.h"
#import <Masonry.h>
#import "Resource.h"

@implementation MusicVideosCollectionCell

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self.titleLabel setTextAlignment:NSTextAlignmentLeft];
        [self.subTitleLable setTextAlignment:NSTextAlignmentLeft];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];

    UIView *superView = self.contentView;
    __weak typeof(self) weakSelf = self;
    UIEdgeInsets insert = UIEdgeInsetsMake(4, 4, 4, 4);


    [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        [make setRemoveExisting:YES];
    }];
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        [make setRemoveExisting:YES];
    }];
    [self.subTitleLable mas_remakeConstraints:^(MASConstraintMaker *make) {
        [make setRemoveExisting:YES];
    }];

    
    [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.mas_equalTo(superView).insets(insert);
        CGFloat w = CGRectGetHeight(superView.bounds)-(insert.top+insert.bottom);
        w *= 1.8; // 高度的1.8倍
        make.width.mas_equalTo(w);
    }];

    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(superView.mas_centerY);
        make.left.mas_equalTo(weakSelf.imageView.mas_right).inset(insert.left);
        make.right.mas_equalTo(superView).inset(insert.right);
    }];

    [self.subTitleLable mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superView.mas_centerY);
        make.left.right.mas_equalTo(weakSelf.titleLabel);
    }];
}

- (void)setResource:(Resource *)resource{
    [super setResource:resource];

    [self.subTitleLable setText:[resource.attributes valueForKey:@"artistName"]];
}
@end
