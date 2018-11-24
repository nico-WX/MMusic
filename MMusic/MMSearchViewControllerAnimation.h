//
//  MMSearchViewControllerAnimation.h
//  SearchController
//
//  Created by 🐙怪兽 on 2018/11/22.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface MMSearchViewControllerAnimation : NSObject<UIViewControllerAnimatedTransitioning>
//present  或者 dismiss 标记
@property(nonatomic, assign) BOOL present;
@end

NS_ASSUME_NONNULL_END
