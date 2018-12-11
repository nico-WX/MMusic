//
//  MMTabBarController.h

//
//  Created by 🐙怪兽 on 2018/11/8.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//容器, 播放器添加到这个容器中
@interface MMTabBarController : UITabBarController
@property(nonatomic, assign,readonly)CGRect popFrame;

- (void)addPopViewController:(UIViewController*)popViewController;
@end

NS_ASSUME_NONNULL_END
