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
        [self addSubview:_titleLable];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];

    __weak typeof(self) weakSelf = self;
    UIEdgeInsets insets = UIEdgeInsetsMake(8, 8, 8, 80);
    [_titleLable mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf).insets(insets);
    }];
}

- (void)setTitle:(NSString *)title{
    if (_title != title) {
        _title = title;
        [_titleLable setText:title];
    }
}
@end
