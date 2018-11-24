//
//  MMDetailPoppingAnimator.h
//  TransitionAnimation
//
//  Created by 🐙怪兽 on 2018/11/12.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MMDetailPoppingAnimator : NSObject<UIViewControllerAnimatedTransitioning>
@property(nonatomic, assign) CGRect startFrame; //起始位置
@property(nonatomic, assign) BOOL presenting;   //present or Dismiss ?

@end

NS_ASSUME_NONNULL_END
