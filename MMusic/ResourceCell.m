//
//  ResourceCell.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/10/3.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <Masonry.h>

#import "ResourceCell.h"
#import "EditorialNotes.h"
#import "Artwork.h"
#import "DetailViewController.h"
#import "MMDetailPoppingAnimator.h"


@implementation ResourceCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {


        _imageView = [[UIImageView alloc] init];
        _titleLabel = [[UILabel alloc] init];

        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_titleLabel setAdjustsFontSizeToFitWidth:YES];
        [_titleLabel setTextColor:MainColor];
        [_titleLabel setFont:[UIFont systemFontOfSize:[UIFont labelFontSize]]];

        [self.contentView addSubview:_imageView];
        [self.contentView addSubview:_titleLabel];

        //set
        //默认全透明, 无法显示阴影  , 设置颜色通道透明
        [self.layer setShadowColor:UIColor.lightGrayColor.CGColor];
        [self.layer setShadowOffset:CGSizeMake(4, 8)];
        [self.layer setShadowOpacity:0.8];
        [self.layer setShadowRadius:6];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];

    UIEdgeInsets insets = UIEdgeInsetsMake(4, 4, 4, 4);
    UIView *superView = self.contentView;
    __weak typeof(self) weakSelf = self;
    [_imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(superView).insets(insets);
        CGFloat h = CGRectGetWidth(superView.bounds) - (insets.left+insets.right);
        make.height.mas_equalTo(h);
    }];

    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(superView);
        make.top.mas_equalTo(weakSelf.imageView.mas_bottom);
    }];
}


-(void)prepareForReuse{
    [super prepareForReuse];
    _resource = nil;
    _imageView.image = NULL;
    _titleLabel.text = NULL;
}

#pragma mark - setter / getter

- (void)setResource:(Resource *)resource{
    if (_resource != resource) {
        _resource = resource;

        [_titleLabel setText:[resource valueForKeyPath:@"attributes.name"]];
        [_imageView setImageWithURLPath:[resource valueForKeyPath:@"attributes.artwork.url"]];
    }
}
- (void)setAlbum:(Album *)album{
    if (_album != album) {
        _album = album;
        [_titleLabel setText:album.name];
        [_imageView setImageWithURLPath:album.artwork.url];
    }
}
- (void)setPlaylists:(Playlist *)playlists{
    if (_playlists != playlists) {
        _playlists = playlists;
        [_titleLabel setText:playlists.name];
        [_imageView setImageWithURLPath:playlists.artwork.url];
    }
}


@end
