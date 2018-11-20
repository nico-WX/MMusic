//
//  MMTabBarController.h

//
//  Created by 🐙怪兽 on 2018/11/8.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**popup 代理*/
@protocol MMTabBarControllerPopupStateDelegate <NSObject>

@optional
//popping 状态
- (void)mmTabBarControllerPopupState:(BOOL)popping whitFrame:(CGRect)frame;
@end

@interface MMTabBarController : UITabBarController
@property(nonatomic, weak)id<MMTabBarControllerPopupStateDelegate> popupStateDelegate;
@property(nonatomic, assign,readonly)CGRect popFrame;

- (void)addPopViewController:(UIViewController*)popViewController;
@end

NS_ASSUME_NONNULL_END
