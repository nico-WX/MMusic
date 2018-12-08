//
//  MMHeartSwitch.m
//  CustomSwitch
//
//  Created by Magician on 2018/7/4.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import "MMHeartSwitch.h"
#import "HeartStyleKit.h"

@interface MMHeartSwitch()
@property(nonatomic, strong) UIImpactFeedbackGenerator *impact;

@end

@implementation MMHeartSwitch

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {

        _impact = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];

        [self setBackgroundColor:[UIColor colorWithWhite:1 alpha:0]];
        [self addTarget:self action:@selector(change) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    if(self.on){
        [HeartStyleKit drawOnCanvasWithFrame:rect resizing:HeartStyleKitResizingBehaviorAspectFit];
    }else{
        [HeartStyleKit drawOffCanvasWithFrame:rect resizing:HeartStyleKitResizingBehaviorAspectFit];
    }
}

- (void)setOn:(BOOL)on{
    _on = on;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsDisplay];
        [self animationButton:self];
    });
}

- (void)change {
    //取反
    [self.impact impactOccurred];
    [self setOn:!_on];
}

//简单的缩小-->恢复原始状态
- (void)animationButton:(MMHeartSwitch*)sender {

    [UIView animateWithDuration:0.2 animations:^{
        [sender setTransform:CGAffineTransformMakeScale(0.8, 0.8)];
    } completion:^(BOOL finished) {
        if (finished){
            [UIView animateWithDuration:0.2 animations:^{
                [sender setTransform:CGAffineTransformIdentity];
            }];
        }
    }];
}

@end
