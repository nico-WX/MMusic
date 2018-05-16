//
//  PlayProgressView.m
//  MMusic
//
//  Created by Magician on 2018/4/14.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import "PlayProgressView.h"
#import <Masonry.h>

@implementation PlayProgressView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupSubview];
    }
    return self;
}

-(void) setupSubview{
    [self setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0]];

    UIColor *defaultColor = UIColor.grayColor;
    UIFont *defaultFont = [UIFont systemFontOfSize:12.0f];
    NSString *defaultText = @"00:00";
    //已经播放时间 标签(进度条左边)
    _currentTime = ({
        UILabel *label = UILabel.new;
        label.font = defaultFont;
        label.textColor = defaultColor;
        label.text = defaultText;
        label.textAlignment = NSTextAlignmentCenter;

        [self addSubview:label];
        label;
    });

    //progress
    _progressSlider = ({
        UISlider *slider = UISlider.new;

        //正常状态 滑块样式
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        view.backgroundColor = UIColor.greenColor;
        [slider setThumbImage:[self getImageFromView:view] forState:UIControlStateNormal];

        //拖动下 滑块样式
        view.frame = CGRectMake(0, 0, 20, 20);
        view.backgroundColor = UIColor.redColor;
        [slider setThumbImage:[self getImageFromView:view] forState:UIControlStateHighlighted];

        [self addSubview:slider];
        slider;
    });

    //总时长
    _durationTime = ({
        UILabel *label = UILabel.new;
        label.textColor = defaultColor;
        label.font = defaultFont;
        label.text = defaultText;
        label.textAlignment = NSTextAlignmentCenter;

        [self addSubview:label];
        label;
    });
}

/**通过视图产生图片 设置到滑块上 */
-(UIImage *)getImageFromView:(UIView*) view{
    //切圆
    view.layer.cornerRadius = CGRectGetHeight(view.bounds)/2;
    view.layer.masksToBounds = YES;

    //转换到相同缩放大小的图片
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
- (void)layoutSubviews{
    //Layout
    __weak typeof(self) weakSelf = self;
    [self.currentTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.mas_top);
        make.left.mas_equalTo(weakSelf.mas_left);
        make.size.mas_equalTo(CGSizeMake(40, CGRectGetHeight(weakSelf.bounds)));
    }];

    [self.progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.mas_top);
        make.left.mas_equalTo(weakSelf.currentTime.mas_right);
        CGFloat w = CGRectGetWidth(weakSelf.bounds) -  80;
        make.size.mas_equalTo(CGSizeMake(w, CGRectGetHeight(weakSelf.bounds)));
    }];

    [self.durationTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.mas_top);
        make.right.mas_equalTo(weakSelf.mas_right);
        make.size.mas_equalTo(CGSizeMake(40, CGRectGetHeight(weakSelf.bounds)));
    }];
}


@end
