//
//  SearchResultsSectionView.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/23.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import <Masonry.h>

#import "SearchResultsSectionView.h"

@interface SearchResultsSectionView ()
@property(nonatomic,strong) UILabel *titleLable;
@end

@implementation SearchResultsSectionView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _titleLable = [[UILabel alloc] init];
        _showMoreButton = [[UIButton alloc] init];
        [self addSubview:_titleLable];
        [self addSubview:_showMoreButton];

        [_showMoreButton setTitleColor:MainColor forState:UIControlStateNormal];
        [_showMoreButton setTitle:@"全部 >" forState:UIControlStateNormal];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];

    __weak typeof(self) weakSelf = self;
    UIEdgeInsets insets = UIEdgeInsetsMake(8, 8, 8, 8);
    [_titleLable mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.mas_equalTo(weakSelf).insets(insets);
        make.width.mas_equalTo(200);
        //make.edges.mas_equalTo(weakSelf).insets(insets);
    }];
    [_showMoreButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.mas_equalTo(weakSelf).insets(insets);
        make.width.mas_equalTo(80);
    }];
}

- (void)setTitle:(NSString *)title{
    if (_title != title) {
        _title = title;
        [_titleLable setText:title];
    }
}
@end
