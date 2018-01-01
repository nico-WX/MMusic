//
//  RecommendDetailCell.m
//  MMusic
//
//  Created by Magician on 2017/12/29.
//  Copyright © 2017年 com.😈. All rights reserved.
//
#import <UIImageView+WebCache.h>

#import "RecommendDetailCell.h"

#import "NSObject+Tool.h"
#import "Artwork.h"
#import "Resource.h"
#import "Playlist.h"
#import "Album.h"
#import "EditorialNotes.h"


@interface RecommendDetailCell()
@property(nonatomic, strong) Playlist *playlist;
@property(nonatomic, strong) Album *album;

@property(nonatomic, strong) UIImageView *artworkView;
@property(nonatomic, strong) UILabel *curatorLabel;
@property(nonatomic, strong) UITextView *descriptionView;
@end

@implementation RecommendDetailCell

- (void)drawRect:(CGRect)rect{
    [self.layer setCornerRadius:8];
    [self.layer setMasksToBounds:YES];
    [self.contentView setBackgroundColor:[UIColor whiteColor]];

    [self setupArtworkImageViewWithRect:rect];
    [self setupTitleLabel];
    [self setupDesc];

}
#pragma mark 添加封面视图
-(void)setupArtworkImageViewWithRect:(CGRect) rect{
    CGFloat h = rect.size.height;
    CGFloat w = h;
    CGFloat x = rect.origin.x;
    CGFloat y = rect.origin.y;

    CGRect artRect = CGRectMake(x, y, w, h);
    self.artworkView = [[UIImageView alloc] initWithFrame:artRect];
    [self.artworkView.layer setCornerRadius:8];
    [self.artworkView.layer setMasksToBounds:YES];
    [self.contentView addSubview:self.artworkView];

    NSString *path;
    if (self.playlist) {
        path = self.playlist.artwork.url;
    }else if (self.album){
        path = self.album.artwork.url;
    }

    path = [self stringReplacingOfString:path height:h width:w];
    NSURL *artURL = [NSURL URLWithString:path];
    UIActivityIndicatorView *active = [[UIActivityIndicatorView alloc] initWithFrame:artRect];
    [active setHidesWhenStopped:YES];
    [active startAnimating];
    [self.artworkView addSubview:active];

    [self.artworkView sd_setImageWithURL:artURL completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        [active stopAnimating];
        [active removeFromSuperview];
    }];

    //Des

}

#pragma mark 添加标题
-(void)setupTitleLabel{
    //Title
    CGRect artRect = self.artworkView.frame;
    CGFloat lx = CGRectGetMaxX(artRect) + 8;
    CGFloat ly = artRect.origin.y;
    CGFloat lw = self.frame.size.width - artRect.size.width;
    CGFloat lh = 22;
    CGRect lRect = CGRectMake(lx, ly, lw, lh);
    self.curatorLabel = [[UILabel alloc] initWithFrame:lRect];
    [self.contentView addSubview:self.curatorLabel];

    NSString *title = _playlist?_playlist.name:_album.name;
    [self.curatorLabel setText:title];

    //添加专辑歌手名称
    if (_album) {
        CGRect artRect = CGRectMake(lx, ly+lh+2, lw, lh);
        UILabel *artistLab = [[UILabel alloc] initWithFrame:artRect];
        [self.contentView addSubview:artistLab];
        [artistLab setTextColor:[UIColor lightGrayColor]];
        [artistLab setText:_album.artistName];
    }
}
#pragma mark 添加介绍  <歌单才有>
-(void)setupDesc{
    if (_playlist) {
        CGRect rect = self.curatorLabel.frame;
        CGFloat dx = rect.origin.x;
        CGFloat dy = CGRectGetMaxY(rect) + 2;
        CGFloat dw = CGRectGetWidth(rect);
        CGFloat dh = self.frame.size.height - CGRectGetHeight(rect)-2;

        CGRect desRect = CGRectMake(dx, dy, dw, dh);
        self.descriptionView = [[UITextView alloc] initWithFrame:desRect];
        [self.contentView addSubview:_descriptionView];
        [self.descriptionView setText:_playlist.desc.standard];
        [self.descriptionView setTextColor:[UIColor lightGrayColor]];
        [self.descriptionView setEditable:NO];

    }
}

#pragma mark 在set方法中判断类型 实例化对应的类型对象
-(void)setResource:(Resource *)resource{
    if (_resource != resource) {
        _resource = resource;

        //通用属性 实例到具体的资源
        if ([_resource.type isEqualToString:@"playlists"]) {
            _playlist = [Playlist instanceWithDict:_resource.attributes];
        }else if ([_resource.type isEqualToString:@"albums"]){
            _album = [Album instanceWithDict:_resource.attributes];
        }
    }
}


@end
