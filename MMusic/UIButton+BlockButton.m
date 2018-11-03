//
//  UIButton+BlockButton.m
//  MMusic
//
//  Created by Magician on 2018/4/17.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import "UIButton+BlockButton.h"

@implementation UIButton (BlockButton)

static char overviewKey;

@dynamic event;

//将Block 关联到对象中, 并在响应中,调用Block
- (void)handleControlEvent:(UIControlEvents)controlEvent withBlock:(ActionBlock)action{
    objc_setAssociatedObject(self, &overviewKey,action, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self addTarget:self action:@selector(callActionBlock:) forControlEvents:controlEvent];
}

- (void)callActionBlock:(id)sender {
    ActionBlock block = (ActionBlock)objc_getAssociatedObject(self, &overviewKey);  //取出关联的对象, 如果有定义,执行Block
    if (block) {
        block();
    }
}
@end
