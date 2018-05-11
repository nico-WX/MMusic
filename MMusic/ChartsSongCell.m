//
//  ChartsSongCell.m
//  MMusic
//
//  Created by Magician on 2018/4/24.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import "ChartsSongCell.h"

@implementation ChartsSongCell

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {

        UIEdgeInsets padding = UIEdgeInsetsMake(2, 2, 2, 2);
        self.artworkView.frame = ({
            CGFloat x = padding.left;
            CGFloat y = padding.top;
            CGFloat h = CGRectGetHeight(frame) - y*2;
            CGFloat w = h;
            CGRectMake(x, y, w, h);
        });

        self.titleLabel.frame = ({
            CGRect artworkFrame = self.artworkView.frame;
            CGFloat x = CGRectGetMaxX(artworkFrame)+padding.left;
            CGFloat y = padding.top;
            CGFloat w = CGRectGetWidth(frame)-padding.left*3 - CGRectGetWidth(artworkFrame);
            CGFloat h = CGRectGetHeight(frame) *0.6 - padding.top;
            CGRectMake(x, y, w, h);
        });

        self.artistLabel.frame = ({
            CGRect titleFrame = self.titleLabel.frame;
            CGFloat x = CGRectGetMinX(titleFrame);
            CGFloat y = CGRectGetMaxY(titleFrame);
            CGFloat w = CGRectGetWidth(titleFrame);
            CGFloat h = CGRectGetHeight(frame) - CGRectGetHeight(titleFrame) - padding.bottom;
            CGRectMake(x, y, w, h);
        });

    }
    return self;
}

-(void)drawRect:(CGRect)rect{
    self.artistLabel.font = [UIFont systemFontOfSize:12];
    self.artistLabel.textColor = UIColor.grayColor;
}

@end
