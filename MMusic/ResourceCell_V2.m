//
//  ResourceCell_V2.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/10/3.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import "ResourceCell_V2.h"
#import <Masonry.h>
#import "EditorialNotes.h"
#import "Artwork.h"


@implementation ResourceCell_V2
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _imageView = UIImageView.new;
        _titleLabel = UILabel.new;

        //add to contentView
        [self.contentView addSubview:_imageView];
        [self.contentView addSubview:_titleLabel];

        //set
        //默认全透明, 无法显示阴影
        [self setBackgroundColor:UIColor.whiteColor];
        [self.layer setShadowColor:UIColor.lightGrayColor.CGColor];
        [self.layer setShadowOffset:CGSizeMake(5, 10)];
        [self.layer setShadowOpacity:0.7];
        [self.layer setShadowRadius:8];

        //text
        [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [self.titleLabel setAdjustsFontSizeToFitWidth:YES];         //调整字体

        //layout
        UIView *superView = self.contentView;
        typeof(self) weakSelf = self;
        [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(superView.mas_left);
            make.top.mas_equalTo(superView.mas_top);
            make.right.mas_equalTo(superView.mas_right);
            make.height.mas_equalTo(CGRectGetWidth(superView.frame));
        }];

        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(superView.mas_left);
            make.right.mas_equalTo(superView.mas_right);
            make.bottom.mas_equalTo(superView.mas_bottom);
            make.top.mas_equalTo(weakSelf.imageView.mas_bottom);
        }];
    }
    return self;
}


-(void)prepareForReuse{
    _imageView.image = NULL;
    _titleLabel.text = NULL;
    [super prepareForReuse];
}

-(void)setAlbum:(Album *)album{
    if (_album != album) {
        _album = album;

        self.titleLabel.text = album.name;

        Artwork *artwork = album.artwork;
        [self showImageToView:self.imageView withImageURL:artwork.url cacheToMemory:YES];
    }
}
-(void)setPlaylists:(Playlist *)playlists{
    if (_playlists != playlists) {
        _playlists = playlists;

        self.titleLabel.text = playlists.name;
        Artwork *artwork = playlists.artwork;
        [self showImageToView:self.imageView withImageURL:artwork.url cacheToMemory:YES];
    }
}
@end
