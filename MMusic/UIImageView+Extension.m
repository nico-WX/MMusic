//
//  UIImageView+Extension.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/12.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <objc/runtime.h>
#import <JGProgressHUD.h>
#import "UIImageView+Extension.h"
#import <UIImageView+WebCache.h>
#import <UIView+WebCache.h>
#import <AFNetworking.h>

@interface UIImageView ()
@end

@implementation UIImageView (Extension)

-(void)setImageWithURLPath:(NSString *)path{
    
    NSString *md5Path = IMAGE_PATH_FOR_URL(path);
    UIImage *image = [UIImage imageWithContentsOfFile:md5Path];
    [self setImage:image];

    if (!image) {

        [self setBackgroundColor:[UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1]];

        [self sd_addActivityIndicator];
        [self sd_setShowActivityIndicatorView:YES];


        path = [path stringReplacingImageURLSize:self.bounds.size];
        [self sd_setImageWithURL:[NSURL URLWithString:path]
                placeholderImage:nil
                         options:SDWebImageRetryFailed
                       completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL)
        {
            [self sd_setShowActivityIndicatorView:NO];
        }];
    }
}




@end
