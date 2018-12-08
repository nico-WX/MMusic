//
//  UIControl+MMActionBlock.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/12/8.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import "UIControl+MMActionBlock.h"

@implementation UIControl (MMActionBlock)


//static char overviewKey;

@dynamic event;

//将Block 关联到对象中, 并在响应中,调用Block
- (void)handleControlEvent:(UIControlEvents)controlEvent withBlock:(ActionBlock)action{
    objc_setAssociatedObject(self,@selector(callActionBlock:),action, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self addTarget:self action:@selector(callActionBlock:) forControlEvents:controlEvent];
}

- (void)callActionBlock:(id)sender {
    ActionBlock block = (ActionBlock)objc_getAssociatedObject(self, @selector(callActionBlock:));  //取出关联的对象, 如果有定义,执行Block
    if (block) {
        block();
    }
}
@end
