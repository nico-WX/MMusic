//
//  MMTabBarController.h
//  ScrollPage
//
//  Created by 🐙怪兽 on 2018/11/8.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MMTabBarController : UITabBarController
- (void)addPopupViewController:(UIViewController*)popupViewController;
- (void)addOpenViewController:(UIViewController*)openViewController;
@end

NS_ASSUME_NONNULL_END
