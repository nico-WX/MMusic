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
        [_titleLabel sizeToFit];
        [_titleLabel setAdjustsFontSizeToFitWidth:YES];
        [_artistLabel setAdjustsFontSizeToFitWidth:YES];

        self.backgroundColor = UIColor.whiteColor;
        [self.contentView addSubview:_titleLabel];
        [self.contentView addSubview:_artistLabel];
        [self.contentView addSubview:_artworkView];

        [self prepareForReuse];
    }
    return self;
}

//消除重用存在的 旧资源(文本/图片 等)
-(void)prepareForReuse{
    [super prepareForReuse];
    _artworkView.image = nil;
    _titleLabel.text = nil;
    _artistLabel.text = nil;

}

@end
