//
//  ChartsSongCell.m
//  MMusic
//
//  Created by Magician on 2018/4/7.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import "ChartsSongCell.h"
#import <Masonry.h>

@implementation ChartsSongCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {

        self.artworkView = UIImageView.new;
        self.artworkView.layer.cornerRadius = 4.0f;
        self.artworkView.layer.masksToBounds = YES;
        self.nameLabel = UILabel.new;

        self.artistLabel = UILabel.new;
        self.artistLabel.textColor = UIColor.darkGrayColor;
        self.artistLabel.font = [UIFont systemFontOfSize:12.0f];

        self.artworkView.backgroundColor = UIColor.lightGrayColor;

        [self.contentView addSubview:self.artworkView];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.artistLabel];

        UIEdgeInsets padding = UIEdgeInsetsMake(2, 2, 2, 2);
        UIView *superview = self.contentView;
        [self.artworkView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(superview.mas_top).with.offset(padding.top);
            make.left.mas_equalTo(superview.mas_left).with.offset(padding.left);
            make.bottom.mas_equalTo(superview.mas_bottom).with.offset(-padding.bottom);
            CGFloat w = CGRectGetHeight(superview.bounds)-padding.top*2;
            make.width.mas_equalTo(@(w));
        }];

        __weak typeof(self) weakSelf = self;
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            //size
            CGFloat h = CGRectGetHeight(superview.bounds)-padding.top-padding.bottom;
            h = h*0.6f;
            CGFloat w = CGRectGetWidth(superview.bounds)*0.8;
            make.size.mas_equalTo(CGSizeMake(w, h));

            //xy
            make.top.mas_equalTo(superview.mas_top).with.offset(padding.top);
            make.left.mas_equalTo(weakSelf.artworkView.mas_right).with.offset(padding.left);
        }];

        [self.artistLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(weakSelf.nameLabel.mas_bottom);
            make.left.mas_equalTo(weakSelf.artworkView.mas_right).with.offset(padding.left);
            make.bottom.mas_equalTo(superview.mas_bottom).with.offset(-padding.bottom);
            make.width.mas_equalTo(weakSelf.nameLabel.mas_width);
        }];
    }
    return self;
}

@end
