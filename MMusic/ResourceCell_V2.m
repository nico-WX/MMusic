//
//  ResourceCell_V2.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/10/3.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import "ResourceCell_V2.h"
#import <Masonry.h>
#import "EditorialNotes.h"
#import "Artwork.h"
#import "MMDetailViewController.h"
#import "MMDetailPoppingAnimator.h"

@interface ResourceCell_V2 ()

@end

@implementation ResourceCell_V2
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {

        // 实例化变量 && set
        ({
            _imageView = [UIImageView new];
            _titleLabel = [UILabel new];

            [_titleLabel setTextAlignment:NSTextAlignmentCenter];
            [_titleLabel setAdjustsFontSizeToFitWidth:YES];
        });

        //self set
        ({
            //add
            [self.contentView addSubview:_imageView];
            [self.contentView addSubview:_titleLabel];

            //set
            //默认全透明, 无法显示阴影  , 设置颜色通道透明
            //[self setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0]];
            [self.layer setShadowColor:UIColor.lightGrayColor.CGColor];
            [self.layer setShadowOffset:CGSizeMake(5, 10)];
            [self.layer setShadowOpacity:0.8];
            [self.layer setShadowRadius:8];
        });
    }
    return self;
}

- (void)layoutSubviews{
    //layout
    ({
        UIView *superView = self.contentView;
        __weak typeof(self) weakSelf = self;
        [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(superView.mas_left);
            make.top.mas_equalTo(superView.mas_top);
            make.right.mas_equalTo(superView.mas_right);
            make.height.mas_equalTo(CGRectGetWidth(superView.frame));
        }];

        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(superView.mas_left);
            make.right.mas_equalTo(superView.mas_right);
            make.bottom.mas_equalTo(superView.mas_bottom);
            make.top.mas_equalTo(weakSelf.imageView.mas_bottom);
        }];
    });

    [super layoutSubviews];
}


-(void)prepareForReuse{

    _resource = nil;
    _imageView.image = NULL;
    _titleLabel.text = NULL;
    [super prepareForReuse];
}

- (void)setResource:(Resource *)resource{
    if (_resource != resource) {
        _resource = resource;

        [_titleLabel setText:[resource valueForKeyPath:@"attributes.name"]];
        [_imageView setImageWithURLPath:[resource valueForKeyPath:@"attributes.artwork.url"]];
    }
}



@end
