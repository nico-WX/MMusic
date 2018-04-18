//
//  UIButton+BlockButton.h
//  MMusic
//
//  Created by Magician on 2018/4/17.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

typedef void (^ActionBlock)(void);
@interface UIButton (BlockButton)
@property (readonly) NSMutableDictionary *event;

- (void) handleControlEvent:(UIControlEvents)controlEvent withBlock:(ActionBlock)action;
@end
