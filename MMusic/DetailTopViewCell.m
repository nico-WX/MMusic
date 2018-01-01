//
//  DetailTopViewCell.m
//  MMusic
//
//  Created by Magician on 2017/12/7.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "NSObject+Tool.h"
#import "DetailTopViewCell.h"
#import "Playlist.h"
#import "Album.h"
#import "Artwork.h"

#import <UIImageView+WebCache.h>

@interface DetailTopViewCell()
@property(nonatomic, strong) Album *alubm;
@property(nonatomic, strong) Playlist *playlist;
@property(nonatomic, copy) NSString *artworkURL;
@property(nonatomic, nonnull, strong) UIImageView *artworkImageView;
@end

@implementation DetailTopViewCell

- (void)drawRect:(CGRect)rect{
    [self.layer setCornerRadius:5];
    [self.layer setMasksToBounds:YES];
    [self.contentView setBackgroundColor:[UIColor whiteColor]];

    [self setupImageViewWithRect:rect];
}

- (void)setupImageViewWithRect:(CGRect) rect{

    //活动指示器
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithFrame:rect];
    [self.contentView addSubview:activity];
    [activity startAnimating];
    [activity setColor:[UIColor greenColor]];

    //海报请求大小
    int h = (int)rect.size.height;
    int w = (int)rect.size.width;
    NSString *path = [self stringReplacingOfString:self.artworkURL height:h width:w]; //替换URL 参数
    NSURL *imageURL = [NSURL URLWithString:path];
    [self.artworkImageView sd_setImageWithURL:imageURL completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        [activity stopAnimating];
        [activity setHidesWhenStopped:YES];
    }];
    [self.contentView addSubview:self.artworkImageView];
}

-(UIImageView *)artworkImageView{
    if (!_artworkImageView) {
        _artworkImageView = [[UIImageView alloc] initWithFrame:self.contentView.frame];
    }
    return _artworkImageView;
}
- (void)setResource:(Resource *)resource{
    if (_resource != resource) {
        _resource = resource;
    }

    //不同的模型
    if ([_resource.type isEqualToString:@"albums"]) {
        _alubm = [Album instanceWithDict:_resource.attributes];
        _artworkURL = _alubm.artwork.url;
    }
    if ([_resource.type isEqualToString:@"playlists"]) {
        _playlist = [Playlist instanceWithDict:_resource.attributes];
        _artworkURL = _playlist.artwork.url;
    }
}
@end
