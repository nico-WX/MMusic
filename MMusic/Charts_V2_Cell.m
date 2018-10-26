//
//  Charts_V2_Cell.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/10/26.
//  Copyright © 2018年 com.😈. All rights reserved.
//
#import <Masonry.h>
#import "Charts_V2_Cell.h"
@interface Charts_V2_Cell()

@end

@implementation Charts_V2_Cell
- (instancetype)initWithFrame:(CGRect)frame{
    if (self= [super initWithFrame:frame]) {
        _titleLable = [[UILabel alloc] init];
        _imageView = [[UIImageView alloc] init];
        [_imageView setContentMode:UIViewContentModeScaleToFill]; //缩放填充

        [self.contentView addSubview:_imageView];
        [self.contentView addSubview:_titleLable];
    }
    return self;
}
-(void)layoutSubviews{
    UIView *superView = self.contentView;
    [self.titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superView.mas_top);
        make.left.mas_equalTo(superView.mas_left);
        make.right.mas_equalTo(superView.mas_right);
    }];

    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {

    }];

    [super layoutSubviews];
}




@end
