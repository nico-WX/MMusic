//
//  HeadCell.m
//  MMusic
//
//  Created by Magician on 2018/3/7.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import "TodaySectionView.h"

@interface TodaySectionView()
@end

@implementation TodaySectionView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {

        CGFloat spacing = 6;
        CGFloat x = spacing;
        CGFloat y = 0;
        CGFloat w = CGRectGetWidth(frame)-spacing*2;
        CGFloat h = CGRectGetHeight(frame);
        CGRect labelFrame = CGRectMake(x,y,w,h);
        _titleLabel = [[UILabel alloc] initWithFrame:labelFrame];
        [_titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:26.0]];

        [self addSubview:_titleLabel];
    }
    return self;
}


@end
