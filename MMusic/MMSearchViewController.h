//
//  MMSearchViewController.h
//  SearchController
//
//  Created by 🐙怪兽 on 2018/11/22.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MMSearchViewController;

@protocol MMSearchViewControllerDelegate <NSObject>
@optional
- (void)presentSearchViewController:(MMSearchViewController*)searchViewController;
//- (void)dismissSearchViewController:(MMSearchViewController*)searchViewcontroller;

@end

@interface MMSearchViewController : UIViewController
// 添加到导航栏, 其他都不需要做
@property(nonatomic, strong, readonly) UISearchBar *searchBar;
// 显示与dismiss 代理
@property(nonatomic, weak) id<MMSearchViewControllerDelegate> presentDelegate;
@end

NS_ASSUME_NONNULL_END
