//
//  MMSearchContentMusicVideosCell.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/25.
//  Copyright © 2018 com.😈. All rights reserved.
//
#import <Masonry.h>
#import "MMSearchContentMusicVideosCell.h"

@implementation MMSearchContentMusicVideosCell

- (void)layoutSubviews{
    [super layoutSubviews];

    //重新布局图片视图 size
    UIView *superView = self.contentView;
    UIEdgeInsets padding = UIEdgeInsetsMake(4, 4, 4, 4);

    [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.mas_equalTo(superView).insets(padding);
        CGFloat times = 1.6;
        CGFloat h = CGRectGetHeight(superView.bounds) - (padding.top+padding.bottom);
        CGFloat w = h *times;
        make.width.mas_equalTo(w);
    }];


}
@end
