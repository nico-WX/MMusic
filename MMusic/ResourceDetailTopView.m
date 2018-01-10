//
//  ResourceDetailTopView.m
//  MMusic
//
//  Created by Magician on 2017/12/31.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "ResourceDetailTopView.h"
#import "Album.h"
#import "Playlist.h"
#import "Artwork.h"
#import "NSObject+Tool.h"
#import <UIImageView+WebCache.h>

@implementation ResourceDetailTopView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

- (void)drawRect:(CGRect)rect {
    // Drawing code
    //[self setBackgroundColor:[UIColor whiteColor]];

    [self setupArtworkViewWithRect:rect];
}
- (void)setupArtworkViewWithRect:(CGRect)rect {
    Artwork *art = self.playlist.artwork;
    if (!art) art = self.album.artwork;

    CGRect artRect = CGRectMake(0, 0,rect.size.height, rect.size.height);
    UIImageView *artView = [[UIImageView alloc] initWithFrame:artRect];
    [self addSubview:artView];
    [artView.layer setCornerRadius:8];
    [artView.layer setMasksToBounds:YES];
    NSString *path = [self stringReplacingOfString:art.url height:100 width:100];
    NSURL *artURL = [NSURL URLWithString:path];
    [artView sd_setImageWithURL:artURL completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {

    }];
}
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor whiteColor]];
    }
    return self;
}


@end
