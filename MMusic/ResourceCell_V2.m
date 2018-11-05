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
        //默认全透明, 无法显示阴影  , 设置颜色通道透明
        [self setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0]];
        [self.layer setShadowColor:UIColor.lightGrayColor.CGColor];
        [self.layer setShadowOffset:CGSizeMake(5, 10)];
        [self.layer setShadowOpacity:0.8];
        [self.layer setShadowRadius:8];

        //text
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_titleLabel setAdjustsFontSizeToFitWidth:YES];         //调整字体

        //layout
        UIView *superView = self.contentView;
        __weak typeof(self) weakSelf = self;
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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    [UIView animateWithDuration:0.3 animations:^{
        [self setTransform:CGAffineTransformMakeScale(0.9, 0.9)];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            [self setTransform:CGAffineTransformIdentity];
        }];
    }];
    
    [super touchesBegan:touches withEvent:event];
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
        [self showImageToView:self.imageView withImageURL:album.artwork.url cacheToMemory:YES];
    }
}
-(void)setPlaylists:(Playlist *)playlists{
    if (_playlists != playlists) {
        _playlists = playlists;

        self.titleLabel.text = playlists.name;
        [self showImageToView:self.imageView withImageURL:playlists.artwork.url cacheToMemory:YES];
    }
}
@end
