//
//  ChartsCell.m
//  MMusic
//
//  Created by Magician on 2018/4/24.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import "ChartsCell.h"

@implementation ChartsCell
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _titleLabel = UILabel.new;
        _artistLabel = UILabel.new;
        _artworkView = UIImageView.new;

        self.backgroundColor = UIColor.whiteColor;
        [self.contentView addSubview:_titleLabel];
        [self.contentView addSubview:_artistLabel];
        [self.contentView addSubview:_artworkView];
    }
    return self;
}

@end
