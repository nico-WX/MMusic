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

-(void)imageWithURLPath:(NSString *)path{
    NSString *md5Path = IMAGE_PATH_FOR_URL(path);
    UIImage *image = [UIImage imageWithContentsOfFile:md5Path];
    [self setImage:image];

    if (!image) {
        path = [path stringReplacingImageURLSize:self.bounds.size];
        [self sd_setImageWithURL:[NSURL URLWithString:path]];
    }
}

@end
