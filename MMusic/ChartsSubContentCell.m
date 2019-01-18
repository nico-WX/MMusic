//
//  ChartsSubContentCell.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/17.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import <Masonry.h>
#import <UIImageView+WebCache.h>
#import "UIImageView+Extension.h"

#import "ChartsSubContentCell.h"
#import "Resource.h"

@interface ChartsSubContentCell ()
@end

@implementation ChartsSubContentCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _imageView = [[UIImageView alloc] init];
        _titleLabel = [[UILabel alloc] init];
        _subTitleLable = [[UILabel alloc] init];

        [self.contentView addSubview:_imageView];
        [self.contentView addSubview:_titleLabel];
        [self.contentView addSubview:_subTitleLable];

        [_titleLabel adjustsFontSizeToFitWidth];
        [_subTitleLable setTextColor:UIColor.grayColor];
        UIFont *subTitleFont = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
        [_subTitleLable setFont:subTitleFont];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];

    //设置数据才布局
    UIView *superView = self.contentView;
    __weak typeof(self) weakSelf = self;

    [_imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(superView);
        make.height.mas_equalTo(CGRectGetWidth(superView.bounds));
    }];
    [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(superView).insets(UIEdgeInsetsMake(0, 4, 0, 4));
        make.top.mas_equalTo(weakSelf.imageView.mas_bottom);
    }];
    [_subTitleLable mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(superView).insets(UIEdgeInsetsMake(0, 4, 0, 4));
        make.top.mas_equalTo(weakSelf.titleLabel.mas_bottom);
    }];
}


- (void)setResource:(Resource *)resource{
    if (_resource != resource) {
        _resource = resource;
        
        [_titleLabel setText:[resource.attributes valueForKey:@"name"]];
        [_subTitleLable setText:[resource.attributes valueForKey:@"curatorName"]];
        NSString *url = [resource.attributes valueForKeyPath:@"artwork.url"];
        [_imageView setImageWithURLPath:url];
        [self setNeedsLayout];
    }
}
@end
