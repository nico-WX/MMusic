//
//  SongCell.m
//  MMusic
//
//  Created by Magician on 2018/3/11.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <Masonry.h>
#import "SongCell.h"

@implementation SongCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {

        self.artworkView = UIImageView.new;
        [self.contentView addSubview:self.artworkView];

        self.songNameLabel = ({
            UILabel *label = [[UILabel alloc] init];
            [self.contentView addSubview:label];
            label;
        });

        self.artistLabel = ({
            UILabel *label = [[UILabel alloc] init];
            [label setFont:[UIFont systemFontOfSize:12]];
            [label setTextColor:[UIColor grayColor]];
            [self.contentView addSubview:label];
            label;
        });
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    UIEdgeInsets padding = UIEdgeInsetsMake(2, 2, 2, 2);

    __weak typeof(self) weakSelf = self;
    UIView *superview = self.contentView;
    [self.artworkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superview.mas_top).with.offset(padding.top);
        make.left.mas_equalTo(superview.mas_left).with.offset(padding.left);
        make.bottom.mas_equalTo(superview.mas_bottom).with.offset(-padding.bottom);
        CGFloat w = CGRectGetHeight(superview.bounds)-padding.top-padding.bottom;
        make.width.mas_equalTo(w);
    }];

    [self.songNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superview.mas_top).with.offset(padding.top);
        make.left.mas_equalTo(weakSelf.artworkView.mas_right).with.offset(padding.left);
        make.right.mas_equalTo(superview.mas_right).with.offset(-padding.right);
        CGFloat h = CGRectGetHeight(superview.bounds)-padding.top-padding.bottom;
        make.height.mas_equalTo(h*0.6);
    }];

    [self.artistLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.songNameLabel.mas_bottom);
        make.left.mas_equalTo(weakSelf.artworkView.mas_right).with.offset(padding.left);
        make.right.mas_equalTo(superview.mas_right).with.offset(-padding.right);
        make.bottom.mas_equalTo(superview.mas_bottom).with.offset(-padding.bottom);
    }];
}


@end
