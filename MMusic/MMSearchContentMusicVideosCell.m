//
//  MMSearchContentMusicVideosCell.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/25.
//  Copyright © 2018 com.😈. All rights reserved.
//
#import <Masonry.h>
#import "MMSearchContentMusicVideosCell.h"

#import "Resource.h"

@interface MMSearchContentMusicVideosCell ()
@property(nonatomic, strong) UILabel *durationLabel;
@end

@implementation MMSearchContentMusicVideosCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _durationLabel = [[UILabel alloc] init];
        [_durationLabel setBackgroundColor:UIColor.darkTextColor];
        [_durationLabel setTextColor:UIColor.lightTextColor];
        [_durationLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
        [_durationLabel.layer setCornerRadius:2];
        [_durationLabel.layer setMasksToBounds:YES];

        [self.imageView addSubview:_durationLabel];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];

    //重新布局图片视图 size
    UIView *superView = self.contentView;
    UIEdgeInsets padding = UIEdgeInsetsMake(4, 4, 4, 4);

    [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.mas_equalTo(superView).insets(padding);
        CGFloat times = 1.78;
        CGFloat h = CGRectGetHeight(superView.bounds) - (padding.top+padding.bottom);
        CGFloat w = h *times;
        make.width.mas_equalTo(w);
    }];

    superView = self.imageView;
    [self.durationLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(superView).offset(-4);
        make.bottom.mas_equalTo(superView).offset(-4);
        make.size.mas_equalTo(CGSizeMake(35, 12));
    }];
}


- (void)setResource:(Resource *)resource{

    if (resource == self.resource) {
        return;
    }

    [super setResource:resource];
    NSString *text = [resource.attributes valueForKey:@"durationInMillis"];
    NSInteger duration = [text integerValue]/1000; //秒

    NSString *str = [NSString stringWithFormat:@"%.02d:%.02d",(int)(duration/60),(int)(duration%60)];
    [_durationLabel setText:str];

    [self setNeedsDisplayInRect:_durationLabel.frame];
}
@end
