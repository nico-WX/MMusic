//
//  UIImageView+Extension.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/12.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import "UIImageView+Extension.h"
#import <UIImageView+WebCache.h>

@implementation UIImageView (Extension)

-(void)setImageWithURLPath:(NSString *)path{
    NSString *md5Path = IMAGE_PATH_FOR_URL(path);
    UIImage *image = [UIImage imageWithContentsOfFile:md5Path];
    [self setImage:image];

    if (!image) {
        UIImage *placeholder = [UIImage imageNamed:@"placeholder"];
        path = [path stringReplacingImageURLSize:self.bounds.size];
        [self sd_setImageWithURL:[NSURL URLWithString:path] placeholderImage:placeholder options:SDWebImageRetryFailed completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            //[self showImageToView:self withImageURL:path cacheToMemory:YES];    // 缓存 image
        }];
    }
}


@end
