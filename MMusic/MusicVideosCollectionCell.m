//
//  MusicVideosCollectionCell.m
//  MMusic
//
//  Created by Magician on 2018/6/17.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import "MusicVideosCollectionCell.h"
#import <Masonry.h>

@implementation MusicVideosCollectionCell

-(void)drawRect:(CGRect)rect{
    UIView *superview = self.contentView;
    __weak typeof(self) weakSelf = self;

    CGFloat artworkH = CGRectGetHeight(rect) *0.86;
    CGFloat nameH    = CGRectGetHeight(rect) *0.07;
    //CGFloat artistH  = CGRectGetHeight(rect) *0.07;

    [self.artworkView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superview.mas_top);
        make.left.mas_equalTo(superview.mas_left);
        make.right.mas_equalTo(superview.mas_right);
        make.height.mas_equalTo(artworkH);
    }];

    [self.nameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.artworkView.mas_bottom);
        make.left.mas_equalTo(superview.mas_left);
        make.right.mas_equalTo(superview.mas_right);
        make.height.mas_equalTo(nameH);
    }];

    //艺人标签 在父类中没有添加约束
    [self.artistLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.nameLabel.mas_bottom);
        make.left.mas_equalTo(superview.mas_left);
        make.right.mas_equalTo(superview.mas_right);
        make.bottom.mas_equalTo(superview.mas_bottom);
    }];

    [self.nameLabel setTextAlignment:NSTextAlignmentLeft];
    [self.artistLabel setTextAlignment:NSTextAlignmentLeft];
    [self.artistLabel setTextColor:UIColor.grayColor];
}
@end
