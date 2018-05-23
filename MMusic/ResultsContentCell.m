//
//  ResultsContentCell.m
//  MMusic
//
//  Created by Magician on 2018/5/22.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <Masonry.h>

#import "ResultsContentCell.h"

@implementation ResultsContentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _nameLabel = UILabel.new;
        _artistLabel = UILabel.new;
        _descLabel = UILabel.new;

        [self.contentView addSubview:_nameLabel];
        [self.contentView addSubview:_artistLabel];
        [self.contentView addSubview:_descLabel];

        [self setNeedsUpdateConstraints];
    }

    return self;
}

-(void)prepareForReuse{
    [super prepareForReuse];
    self.imageView.image = nil;
    self.nameLabel.text = nil;
    self.artistLabel.text = nil;
    self.descLabel.text = nil;
}

- (void)setNeedsUpdateConstraints{

    __weak typeof(self) weakSelf = self;
    UIView *superview = self.contentView;
    UIEdgeInsets padding = UIEdgeInsetsMake(4, 4, 4, 4);
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superview.mas_top).offset(padding.top);
        make.left.mas_equalTo(superview.mas_left).offset(padding.left);
        make.bottom.mas_equalTo(superview.mas_bottom).offset(-padding.bottom);

        CGFloat w  = CGRectGetHeight(superview.frame)-(padding.top+padding.bottom);
        make.width.mas_equalTo(w);
    }];

    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superview.mas_top).offset(padding.top);
        make.left.mas_equalTo(weakSelf.imageView.mas_right).offset(padding.left);

        CGFloat imageW = CGRectGetWidth(weakSelf.imageView.frame);
        make.right.mas_equalTo(superview.mas_right).offset(-(imageW+padding.right));

        CGFloat h = CGRectGetHeight(weakSelf.imageView.frame)*0.4;
        make.height.mas_equalTo(h);
    }];

    [self.artistLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.nameLabel.mas_bottom);
        make.left.mas_equalTo(weakSelf.nameLabel.mas_left);
        make.right.mas_equalTo(weakSelf.nameLabel.mas_right);

        CGFloat h = CGRectGetHeight(weakSelf.imageView.frame)*0.3;
        make.height.mas_equalTo(h);
    }];

    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.artistLabel.mas_bottom);
        make.left.mas_equalTo(weakSelf.artistLabel.mas_left);
        make.right.mas_equalTo(weakSelf.artistLabel.mas_right);

        CGFloat h = CGRectGetHeight(weakSelf.imageView.frame)*0.3;
        make.height.mas_equalTo(h);
    }];


    [super setNeedsUpdateConstraints];
}



@end


