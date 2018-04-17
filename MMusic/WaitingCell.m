//
//  WaitingCell.m
//  MMusic
//
//  Created by Magician on 2018/4/9.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import "WaitingCell.h"
#import <Masonry.h>

@implementation WaitingCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _name = UILabel.new;
        _artistName = UILabel.new;
        _artworkView = UIImageView.new;

        [self.contentView addSubview:_name];
        [self.contentView addSubview:_artistName];
        [self.contentView addSubview:_artworkView];

        _artistName.textColor = UIColor.grayColor;
        _artistName.font = [UIFont systemFontOfSize:11];

        _name.font = [UIFont systemFontOfSize:14];
    }
    return self;
}

//- (void)awakeFromNib {
//    [super awakeFromNib];
//    // Initialization code
//}
//
//- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];
//
//    // Configure the view for the selected state
//}
-(void)drawRect:(CGRect)rect{

    __weak typeof(self) weakSelf = self;
    UIEdgeInsets padding = UIEdgeInsetsMake(2, 2, 2, 2);
    [self.artworkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.mas_top).with.offset(padding.top);
        make.left.mas_equalTo(weakSelf.mas_left).with.offset(padding.left);
        make.bottom.mas_equalTo(weakSelf.mas_bottom).with.offset(-padding.bottom);
        make.width.mas_equalTo(CGRectGetHeight(weakSelf.contentView.bounds)-(padding.top+padding.bottom));
    }];

    [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.mas_top).with.offset(padding.top);
        make.left.mas_equalTo(weakSelf.artworkView.mas_right).with.offset(padding.left*2);
        make.right.mas_equalTo(weakSelf.mas_right).with.offset(-padding.right);
        make.height.mas_equalTo(CGRectGetHeight(weakSelf.contentView.bounds)*0.6);
    }];

    [self.artistName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.name.mas_bottom);
        make.left.mas_equalTo(weakSelf.artworkView.mas_right).with.offset(padding.left*2);
        make.right.mas_equalTo(weakSelf.mas_right).with.offset(-padding.right);
        make.bottom.mas_equalTo(weakSelf.mas_bottom).with.offset(-padding.bottom);
    }];
}

@end
