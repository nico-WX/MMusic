//
//  UIControl+MMActionBlock.h
//  MMusic
//
//  Created by 🐙怪兽 on 2018/12/8.
//  Copyright © 2018 com.😈. All rights reserved.
//



NS_ASSUME_NONNULL_BEGIN

typedef void (^ActionBlock)(void);
@interface UIControl (MMActionBlock)

@property (readonly) NSMutableDictionary *event;
- (void)handleControlEvent:(UIControlEvents)controlEvent withBlock:(ActionBlock)action;
@end

NS_ASSUME_NONNULL_END
