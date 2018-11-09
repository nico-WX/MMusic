//
//  MMTabBarController.h

//
//  Created by 🐙怪兽 on 2018/11/8.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**改变布局*/
@protocol MMTabbarControllerPopupDelegate <NSObject>

@required

/**最小化窗口时调用, bounds 为最小化的窗口bounds 调整布局*/
- (void)mmTabBarControllerDidClosePopupWithBounds:(CGRect)bounds;

/**最大化窗口时调用 bounds 为最大化的窗口bounds 调整布局*/
- (void)mmTabBarControllerDidOpenPopupWithBounds:(CGRect)bounds;
@end

@interface MMTabBarController : UITabBarController
- (void)addPopupViewController:(UIViewController<MMTabbarControllerPopupDelegate>*)popupViewController;
@end

NS_ASSUME_NONNULL_END
