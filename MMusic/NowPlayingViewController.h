//
//  RedViewController.h
//  ScrollPage
//
//  Created by 🐙怪兽 on 2018/11/8.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "TabBarController.h"
#import "Single.h"

NS_ASSUME_NONNULL_BEGIN

@interface NowPlayingViewController : UIViewController

//单例
SingleInterface(PlayerViewController);
@end

NS_ASSUME_NONNULL_END
