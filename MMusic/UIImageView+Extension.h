//
//  UIImageView+Extension.h
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/12.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (Extension)
/**通过未替换参数URL Path 获取图片并设置*/
- (void)setImageWithURLPath:(NSString*)path;

@end

NS_ASSUME_NONNULL_END
