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
    NSString *path;

    CGFloat times =1; //[UIScreen mainScreen].scale;
    NSString *w = [NSString stringWithFormat:@"%d",(int)(imageSize.width * times)];
    NSString *h = [NSString stringWithFormat:@"%d",(int)(imageSize.height * times)]; //注意占位不能是浮点数, 只能是整数, 不然报CFNetwork 385错误
    path = [self stringByReplacingOccurrencesOfString:@"{h}" withString:h];
    path = [self stringByReplacingOccurrencesOfString:@"{w}" withString:w];
    return path;
}
@end
