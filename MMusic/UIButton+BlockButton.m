//
//  UIButton+BlockButton.m
//  MMusic
//
//  Created by Magician on 2018/4/17.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import "UIButton+BlockButton.h"

@implementation UIButton (BlockButton)

//static char overviewKey;

@dynamic event;

//将Block 关联到对象中, 并在响应中,调用Block
- (void)handleControlEvent:(UIControlEvents)controlEvent withBlock:(ActionBlock)action{
    //添加Block
    objc_setAssociatedObject(self, @selector(callActionBlock:),action, OBJC_ASSOCIATION_COPY_NONATOMIC);
    // 转发到事件处理,从处理方法中执行Block
    [self addTarget:self action:@selector(callActionBlock:) forControlEvents:controlEvent];
}

- (void)callActionBlock:(id)sender {
    //取出关联的对象, 如果有定义,执行Block
    ActionBlock block = (ActionBlock)objc_getAssociatedObject(self, @selector(callActionBlock:));
    if (block) {
        block();
    }
}
@end
