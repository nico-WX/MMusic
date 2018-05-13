//
//  ChartsSectionView.m
//  MMusic
//
//  Created by Magician on 2018/5/11.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import "ChartsSectionView.h"

@implementation ChartsSectionView
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _titleLabel = UILabel.new;
        _titleLabel.frame = frame;
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_titleLabel];
    }
    return self;
}
@end
