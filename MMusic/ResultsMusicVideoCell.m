//
//  ResultsMusicVideoCell.m
//  MMusic
//
//  Created by Magician on 2018/5/23.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <Masonry.h>
#import "ResultsMusicVideoCell.h"


@implementation ResultsMusicVideoCell

- (void)drawRect:(CGRect)rect{

    

    __weak typeof(self) weakSelf = self;
    UIView *superview = self.contentView;
    UIEdgeInsets padding = self.padding;

    [self.artworkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superview.mas_top).offset(padding.top);
        make.left.mas_equalTo(superview.mas_left).offset(padding.left);
        make.bottom.mas_equalTo(superview.mas_bottom).offset(-padding.bottom);

        // 1.8 宽高比
        CGFloat w  = (CGRectGetHeight(rect)-(padding.top+padding.bottom))*1.8;
        make.width.mas_equalTo(w);
    }];

    //封面高度
    CGFloat artworkH = (CGRectGetHeight(rect)-(padding.top+padding.bottom));
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superview.mas_top).offset(padding.top);
        make.left.mas_equalTo(weakSelf.artworkView.mas_right).offset(padding.left);

        CGFloat inset = CGRectGetHeight(rect)+(padding.top+padding.bottom);
        make.right.mas_equalTo(superview.mas_right).offset(-inset);

        CGFloat h = artworkH*0.4;
        make.height.mas_equalTo(h);
    }];


    [self.artistLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.nameLabel.mas_bottom);
        make.left.mas_equalTo(weakSelf.nameLabel.mas_left);
        make.right.mas_equalTo(weakSelf.nameLabel.mas_right);

        CGFloat h = artworkH*0.3;
        make.height.mas_equalTo(h);
    }];

    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.artistLabel.mas_bottom);
        make.left.mas_equalTo(weakSelf.artistLabel.mas_left);
        make.right.mas_equalTo(weakSelf.artistLabel.mas_right);

        CGFloat h = artworkH*0.3;
        make.height.mas_equalTo(h);
    }];

}



@end
