//
//  ClassifyCell.m
//  MMusic
//
//  Created by Magician on 2018/5/22.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import "ClassifyCell.h"
#import <Masonry.h>

@implementation ClassifyCell

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1]];
        _titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_titleLabel setAdjustsFontSizeToFitWidth:YES];
        [self.contentView addSubview:_titleLabel];

        UIView *view = [[UIView alloc] initWithFrame:frame];
        view.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
        [self setSelectedBackgroundView:view];

        [self.layer setCornerRadius:4.0f];
        [self.layer setMasksToBounds:YES];
    }
    return self;
}

-(void)prepareForReuse{
    self.titleLabel.text = nil;
}



@end
