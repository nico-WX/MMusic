//
//  ResultsArtistsCell.m
//  MMusic
//
//  Created by Magician on 2018/5/23.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <Masonry.h>
#import "ResultsArtistsCell.h"

@interface ResultsArtistsCell ()
@property(nonatomic, strong) UIView *selectedView;
@end

@implementation ResultsArtistsCell

- (void)drawRect:(CGRect)rect{

    [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];

    __weak typeof(self) weakSelf = self;
    UIEdgeInsets padding = self.padding;
    UIView *superview = self.contentView;

    [self.artworkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superview.mas_top).offset(padding.top);
        make.left.mas_equalTo(superview.mas_left).offset(padding.left);
        make.bottom.mas_equalTo(superview.mas_bottom).offset(-padding.bottom);

        CGFloat w  = CGRectGetHeight(rect)-(padding.top+padding.bottom);
        make.width.mas_equalTo(w);
    }];

    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(weakSelf.artworkView.mas_centerY);

        CGFloat h =  44.0f;
        CGFloat inset = CGRectGetHeight(rect)+(padding.top+padding.bottom)*2;
        CGFloat w = CGRectGetWidth(rect) - inset;
        make.size.mas_equalTo(CGSizeMake(w, h));

        make.left.mas_equalTo(weakSelf.artworkView.mas_right).offset(padding.left);
    }];

    CGFloat corner = (CGRectGetHeight(rect)-(padding.top+padding.bottom))/2;
    [self.artworkView.layer setCornerRadius:corner];
    [self.artworkView.layer setMasksToBounds:YES];
}

@end
