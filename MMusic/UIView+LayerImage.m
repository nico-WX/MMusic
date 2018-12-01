//
//  UIView+LayerImage.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/12/1.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import "UIView+LayerImage.h"

@implementation UIView (LayerImage)


- (UIImage*)imageWithCurrentView{
    return [self imageWithCurrentContext];
}
//当前图层 绘制成图片
- (UIImage*)imageWithCurrentContext{

    UIGraphicsBeginImageContextWithOptions(self.bounds.size, 1, [[UIScreen mainScreen] scale]);
    // UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    [self.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();
    return image;
}

@end
