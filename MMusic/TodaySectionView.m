//
//  HeadCell.m
//  MMusic
//
//  Created by Magician on 2018/3/7.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import "TodaySectionView.h"
#import <Masonry.h>

@interface TodaySectionView()
@end

@implementation TodaySectionView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        //清除颜色
        [self setBackgroundColor:nil];

        CGFloat spacing = 8;
        _titleLabel = UILabel.new;
        [_titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:26.0]];
        [self addSubview:_titleLabel];

        typeof(self) weakSelf = self;
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(weakSelf).insets(UIEdgeInsetsMake(0, spacing, 0, spacing));
        }];
    }
    return self;
}


@end
