//
//  MMSwitch.m
//  CustomSwitch
//
//  Created by Magician on 2018/7/4.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import "MMSwitch.h"

@interface MMSwitch()
@property(nonatomic, strong) UIImpactFeedbackGenerator *impact;
@property(nonatomic, strong) UIImageView *imageView;
@end

@implementation MMSwitch

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {

        [self setBackgroundColor:[UIColor colorWithWhite:1 alpha:0]];
        [self setOn:NO];

        _impact = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [_imageView setImage:[UIImage imageNamed:@"on"]];               //默认图片
        [self addSubview:_imageView];
        [self addTarget:self action:@selector(change) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)layoutSubviews {
    [_imageView setFrame:self.bounds];
    [super layoutSubviews];
}

- (void)change {
    //值取反传递给形参
    [self.impact impactOccurred];
    [self setOn:!_on];
}

- (void)setOn:(BOOL)on {
    _on = on;

    dispatch_async(dispatch_get_main_queue(), ^{
        [self animationButton:self];
        if (on){
            [self.imageView setImage:[UIImage imageNamed:@"on"]];
        }else{
            [self.imageView setImage:[UIImage imageNamed:@"off"]];
        }
    });
}

//简单的缩小-->恢复原始状态
- (void)animationButton:(MMSwitch*)sender {


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
