//
//  BaseViewController.h
//  MMusic
//
//  Created by 🐙怪兽 on 2019/2/17.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseViewController : UIViewController

// 基类控制器 收到token消息调用
- (void)tokenDidUpdate;
@end

NS_ASSUME_NONNULL_END
