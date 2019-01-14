//
//  MMPlayerControlButtonView.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/5.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import <Masonry.h>
#import "MMPlayerControlButtonView.h"
#import "MMPlayerButton.h"

@interface MMPlayerControlButtonView()

@end

@implementation MMPlayerControlButtonView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _previous = [MMPlayerButton playerButtonWithStyle:MMPlayerButtonPreviousStyle];
        _play = [MMPlayerButton playerButtonWithStyle:MMPlayerButtonPlayStyle];
        _next = [MMPlayerButton playerButtonWithStyle:MMPlayerButtonNextStyle];

        [self addSubview:_previous];
        [self addSubview:_play];
        [self addSubview:_next];
        [self setBackgroundColor:[UIColor colorWithWhite:1 alpha:0]];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
//    CGFloat w = 0;
//    if (CGRectGetWidth(self.bounds) < CGRectGetWidth([UIScreen mainScreen].bounds)) {
//        w = CGRectGetWidth(self.bounds)/2;
//    }else{
//        w = CGRectGetWidth(self.bounds)/3;
//    }


    CGFloat h = CGRectGetHeight(self.bounds)-4;
    CGFloat w = h;
    CGSize size = CGSizeMake(w, h);
    CGFloat centerY = 0; //CGRectGetMidY(self.bounds);
    CGFloat centerX = CGRectGetMidX(self.bounds);


    // masonry center 布局参照父视图center与给定CGPoint计算偏移
    CGFloat x1 = -(centerX/2);
    CGFloat x2 = 0;
    CGFloat x3 = centerX/2;

    NSLog(@"x1=%f x2=%f   x3=%f",x1,x2,x3);

    

    [_previous mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(CGPointMake(x1, centerY));
        make.size.mas_equalTo(size);
    }];
    [_play mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(size);
        make.center.mas_equalTo(CGPointMake(x2, centerY));
    }];
    [_next mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(size);
        make.center.mas_equalTo(CGPointMake(x3, centerY));
    }];


//    [_next mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.size.mas_equalTo(size);
//        make.center.mas_equalTo(CGPointMake(x3, centerY));
//    }];
//    [_play mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.size.mas_equalTo(size);
//        make.center.mas_equalTo(CGPointMake(x2, centerY));
//    }];
//    [_previous mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.size.mas_equalTo(size);
//        make.center.mas_equalTo(CGPointMake(x1, centerY));
//    }];

    NSLog(@"self frame =%@",NSStringFromCGRect(self.frame));
    NSLog(@"play frame =%@",NSStringFromCGRect(self.play.frame));
    NSLog(@"next frame =%@",NSStringFromCGRect(self.next.frame));

}

@end
