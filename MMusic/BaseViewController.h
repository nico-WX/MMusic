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
/**授权更新时,会调用这个方法的回调,可以设置刷新数据行为等*/
@property(nonatomic, copy)void(^authorizationManagerDidUpdateHandle)(void);
@end

NS_ASSUME_NONNULL_END
