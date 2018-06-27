//
//  ResourceCell.m
//  MMusic
//
//  Created by Magician on 2018/6/27.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import "Artwork.h"
#import "EditorialNotes.h"
#import "ResourceCell.h"
#import <Masonry.h>
#import <UIImageView+WebCache.h>

@implementation ResourceCell

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        //默认无色, 无法显示阴影
        [self setBackgroundColor:UIColor.whiteColor];
        [self.layer setShadowColor:UIColor.lightGrayColor.CGColor];
        [self.layer setShadowOffset:CGSizeMake(5, 10)];
        [self.layer setShadowOpacity:0.7];
        [self.layer setShadowRadius:8];

        //var
        _imageView =        [UIImageView new];
        _titleLabel =       [UILabel new];
        _descriptionView =  [UITextView new];
        _infoLabel =        [UILabel new];

        //横线, 添加在descriptionView 下方
        UIView *line = [UIView new];
        [line setBackgroundColor:UIColor.lightGrayColor];
        [line setAlpha:0.6];

        //setter
        [_titleLabel setFont:[UIFont systemFontOfSize:30]];
        [_titleLabel setAdjustsFontSizeToFitWidth:YES];
        [_titleLabel setTextColor:UIColor.blackColor];

        [_descriptionView setTextColor:UIColor.darkGrayColor];
        [_descriptionView setEditable:NO];

        [_infoLabel setTextColor:UIColor.lightGrayColor];

        //add sub
        [self.contentView addSubview:_imageView];
        [self.contentView addSubview:_titleLabel];
        [self.contentView addSubview:_descriptionView];
        [self.contentView addSubview:line];
        [self.contentView addSubview:_infoLabel];

        //layout
        //图片设置时需要大小参数, 直接设置,(masonry 最后才布局)
        _imageView.frame = ({
            CGFloat w = CGRectGetWidth(frame);
            CGFloat h = w;
            CGRectMake(0, 0, w, h);
        });

        //其他masonry 布局
        typeof(self) weakSelf = self;
        UIEdgeInsets padding = UIEdgeInsetsMake(5, 10, 10, 5);
        UIView *superview = self.contentView;
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(weakSelf.imageView.mas_bottom).offset(0/*padding.top*/);
            make.left.mas_equalTo(superview.mas_left).offset(padding.left);
            make.right.mas_equalTo(superview.mas_right).offset(-padding.right);
            CGFloat h = 40.0f;
            make.height.mas_equalTo(h);
        }];

        //布局最下面的子视图
        [_infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(superview.mas_left).offset(padding.left);
            make.right.mas_equalTo(superview.mas_right).offset(-padding.right);
            make.bottom.mas_equalTo(superview).offset(0);
            make.height.mas_equalTo(36.0f);
        }];

        [_descriptionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(weakSelf.titleLabel.mas_bottom).offset(padding.top);
            make.left.mas_equalTo(superview.mas_left).offset(padding.left);
            make.right.mas_equalTo(superview.mas_right).offset(-padding.right);
            make.bottom.mas_equalTo(weakSelf.infoLabel.mas_top).offset(-padding.bottom);
        }];

        [line mas_makeConstraints:^(MASConstraintMaker *make) {
           // make.top.mas_equalTo(weakSelf.descriptionView.mas_bottom).offset(5);
            make.left.mas_equalTo(superview.mas_left).offset(padding.left);
            make.right.mas_equalTo(superview.mas_right).offset(-padding.right);
            make.bottom.mas_equalTo(weakSelf.infoLabel.mas_top);
            make.height.mas_equalTo(1);
        }];
    }
    return self;
}

-(void)prepareForReuse{
    [self.imageView setImage:NULL];
    [self.titleLabel setText:NULL];
    [self.descriptionView setText:NULL];
    [self.infoLabel setText:NULL];

    [super prepareForReuse];
}

#pragma mark - setter
-(void)setAlbum:(Album *)album{
    if (_album != album) {
        _album = album;

        self.titleLabel.text = album.name;
        self.infoLabel.text = album.artistName.uppercaseString;

        if (album.editorialNotes) {
            NSString *text =  album.editorialNotes.standard;
            if (!text) {
                text = album.editorialNotes.shortNotes;
            }
            self.descriptionView.text = text;
        }else{

            NSString *text = [NSString string];
            for (NSString *str in album.genreNames) {
                text = [text stringByAppendingString:[NSString stringWithFormat:@"%@\n",str]];
            }

            NSMutableAttributedString *attStr1 = [[NSMutableAttributedString alloc] initWithString:text];

            NSString *date = [NSString stringWithFormat:@"releaseDate: %@",album.releaseDate];
            NSDictionary *dict = @{NSForegroundColorAttributeName:UIColor.blueColor,};
            NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:date attributes:dict];
            [attStr1 appendAttributedString:attStr];
            [self.descriptionView setAttributedText:attStr1];
        }

        Artwork *artwork = album.artwork;
        [self showImageToView:self.imageView withImageURL:artwork.url cacheToMemory:YES];
    }
}
-(void)setPlaylists:(Playlist *)playlists{
    if (_playlists != playlists) {
        _playlists = playlists;

        self.titleLabel.text = playlists.name;
        self.infoLabel.text = playlists.curatorName.uppercaseString;

        NSString *text = playlists.editorialNotes.standard;
        if (!text) {
            text = playlists.editorialNotes.shortNotes;
        }
        self.descriptionView.text = text;
        Artwork *artwork = playlists.artwork;
        [self showImageToView:self.imageView withImageURL:artwork.url cacheToMemory:YES];
    }
}

@end
