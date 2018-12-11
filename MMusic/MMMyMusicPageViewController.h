//
//  MMMyMusicPageViewController.h
//  MMusic
//
//  Created by 🐙怪兽 on 2018/12/11.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMModelController.h"

NS_ASSUME_NONNULL_BEGIN

@interface MMMyMusicPageViewController : UIViewController
// 设置不同的数据源, 获取数据
@property(nonatomic,strong,readonly)UIPageViewController *pageViewController;
@property(nonatomic, strong, readonly)MMModelController *modelController;
- (instancetype)initWithDataSourceModel:(MMModelController*)modelController;

@end

NS_ASSUME_NONNULL_END
