//
//  NSString+Replace.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/12.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import "NSString+Replace.h"

@implementation NSString (Replace)
- (NSString *)stringReplacingImageURLSize:(CGSize)imageSize {

    if (imageSize.width == 0 || imageSize.height == 0) {
        imageSize.width = 200;
        imageSize.height = 200;
    }


    CGFloat times =1; //[UIScreen mainScreen].scale;
    NSString *w = [NSString stringWithFormat:@"%d",(int)(imageSize.width * times)];
    NSString *h = [NSString stringWithFormat:@"%d",(int)(imageSize.height * times)]; //注意占位不能是浮点数, 只能是整数, 不然报CFNetwork 385错误

    NSString *target = @"{w}x{h}";
    NSString *replacStr = [NSString stringWithFormat:@"%@x%@",w,h];

    NSString *path = [self stringByReplacingOccurrencesOfString:target  withString:replacStr];
    return path;
}
@end
