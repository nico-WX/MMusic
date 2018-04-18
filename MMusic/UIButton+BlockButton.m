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

- (void)handleControlEvent:(UIControlEvents)event withBlock:(ActionBlock)block {
    objc_setAssociatedObject(self, &overviewKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self addTarget:self action:@selector(callActionBlock:) forControlEvents:event];
}


- (void)callActionBlock:(id)sender {
    ActionBlock block = (ActionBlock)objc_getAssociatedObject(self, &overviewKey);
    if (block) {
        block();
    }
}
@end
