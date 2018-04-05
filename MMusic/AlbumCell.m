//
//  ChartCell.m
//  MMusic
//
//  Created by Magician on 2018/3/20.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import "AlbumCell.h"

@implementation AlbumCell
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        CGFloat radius = 4.0f;
        [self.layer setCornerRadius:radius];
        [self.layer setMasksToBounds:YES];


        self.artworkView = ({
            UIImageView *imageView = [[UIImageView alloc] init];
            [imageView setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1]];
            [imageView.layer setCornerRadius:radius];
            [imageView.layer setMasksToBounds:YES];
            [self.contentView addSubview:imageView];

            imageView;
        });

        self.name = ({
            UILabel *label = [[UILabel alloc] init];
            [label setTextAlignment:NSTextAlignmentCenter];
            [self.contentView addSubview:label];
            label;
        });
    }
    return self;
}

- (void)layoutSubviews{
    //封面位置
    self.artworkView.frame = ({
        CGFloat w = CGRectGetWidth(self.contentView.bounds);
        CGFloat h = CGRectGetHeight(self.contentView.bounds);
        CGFloat x = CGRectGetMinX(self.contentView.bounds);
        CGFloat y = CGRectGetMinY(self.contentView.bounds);
        CGRect artRect = CGRectMake(x, y, w, h);
        artRect;
    });

    //名称标签位置
    self.name.frame = ({
        CGFloat x = CGRectGetMinX(self.artworkView.frame);
        CGFloat y = CGRectGetMaxY(self.artworkView.frame);
        CGFloat w = CGRectGetWidth(self.artworkView.frame);
        CGFloat h = CGRectGetHeight(self.contentView.bounds) - CGRectGetHeight(self.artworkView.frame);
        CGRect labelRect = CGRectMake(x, y, w, h);
        labelRect;
    });
}
@end
