//
//  LibraryContentCell.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/2/2.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "LibraryContentCell.h"
#import <MediaPlayer/MediaPlayer.h>
#import <Masonry.h>

@interface LibraryContentCell ()
@property(nonatomic,strong) UILabel *titleLable;
@property(nonatomic,strong) UIImageView *artworkView;
@end

@implementation LibraryContentCell


- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _titleLable = [[UILabel alloc] init];
        _artworkView = [[UIImageView alloc] init];

        [_titleLable setTextAlignment:NSTextAlignmentCenter];

        [self.contentView addSubview:_titleLable];
        [self.contentView addSubview:_artworkView];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];

    UIView *superView = self.contentView;
    __weak typeof(self) weakSelf = self;

    [_artworkView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(superView);
        CGFloat w = CGRectGetWidth(superView.bounds);
        make.height.mas_equalTo(w);
    }];
    [_titleLable mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(weakSelf.artworkView);
        make.top.mas_equalTo(weakSelf.artworkView.mas_bottom);
    }];
}


- (void)setItem:(MPMediaItem *)item{
    if (_item != item) {
        _item = item;

        _titleLable.text = [item valueForProperty:MPMediaItemPropertyTitle];
    }
}
@end
