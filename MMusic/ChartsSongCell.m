//
//  ChartsSongCell.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/18.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "ChartsSongCell.h"
#import "Resource.h"
#import <Masonry.h>

@interface ChartsSongCell ()
@property(nonatomic, strong)UIImageView *lineView;
@end

@implementation ChartsSongCell

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _lineView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_lineView setBackgroundColor:UIColor.lightGrayColor];
        [_lineView setAlpha:0.3]; //线条视觉更细
        [self.contentView addSubview:_lineView];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];

    UIEdgeInsets insets = UIEdgeInsetsMake(4, 4, 4, 4);
    UIView *superView = self.contentView;
    __weak typeof(self) weakSelf = self;


    [_lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        UIEdgeInsets lineInsets = UIEdgeInsetsMake(0, 40, 0, 20);
        make.top.mas_equalTo(superView);
        make.left.right.mas_equalTo(superView).insets(lineInsets);
        make.height.mas_equalTo(1);
    }];

    [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.mas_equalTo(superView).insets(insets);
        CGFloat w = CGRectGetHeight(superView.bounds)-(insets.top+insets.bottom);
        make.width.mas_equalTo(w);
    }];
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(superView.mas_centerY);
        //make.top.mas_equalTo(superView).inset(insets.top);
        make.left.mas_equalTo(weakSelf.imageView.mas_right).inset(insets.left);
    }];
    [self.subTitleLable mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.titleLabel.mas_bottom).inset(0);
        make.left.mas_equalTo(weakSelf.imageView.mas_right).inset(insets.left);
    }];

}

- (void)setResource:(Resource *)resource{
    [super setResource:resource];

    if ([resource.type isEqualToString:@"songs"]) {
        [self.subTitleLable setText:[resource.attributes valueForKey:@"artistName"]];
    }
}
@end
