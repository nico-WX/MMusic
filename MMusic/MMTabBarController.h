//
//  MMTabBarController.h

//
//  Created by 🐙怪兽 on 2018/11/8.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface MMTabBarController : UITabBarController
@property(nonatomic, assign,readonly)CGRect popFrame;

- (void)addPopViewController:(UIViewController*)popViewController;
@end

NS_ASSUME_NONNULL_END
