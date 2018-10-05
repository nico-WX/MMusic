//
//  MySwitch.m
//  CustomSwitch
//
//  Created by Magician on 2018/7/4.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import "MySwitch.h"

@interface MySwitch()
@property(nonatomic, strong) UIImageView *imageView;
@end

@implementation MySwitch

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {

        [self setBackgroundColor:UIColor.whiteColor];
        [self setOn:NO];

        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [_imageView setImage:[UIImage imageNamed:@"on"]];               //默认图片
        [self addSubview:_imageView];
        [self addTarget:self action:@selector(change) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(void) change{
    //取反赋值
    [self setOn:!_on];
}
-(void)setOn:(BOOL)on{
    if (_on != on) {
        _on = on;
        [self animationButton:self];
        if (_on)    [_imageView setImage:[UIImage imageNamed:@"on"]];
        else        [_imageView setImage:[UIImage imageNamed:@"off"]];
    }
}

//简单的缩小-->恢复原始状态
-(void) animationButton:(MySwitch*) sender{
    [UIView animateWithDuration:0.2 animations:^{
        [sender setTransform:CGAffineTransformMakeScale(0.8, 0.8)];
    } completion:^(BOOL finished) {
        if (finished){
            //恢复
            [UIView animateWithDuration:0.2 animations:^{
                [sender setTransform:CGAffineTransformIdentity];
            }];
        }
    }];
}


@end
