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
        //[self setupSubview];

        [self setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0]];
        UIColor *defaultColor = UIColor.grayColor;
        UIFont  *defaultFont = [UIFont systemFontOfSize:12.0f];
        NSString *defaultText = @"00:00";


        //已经播放时间 标签(进度条左边)
        _currentTime = UILabel.new;
        _currentTime.font = defaultFont;
        _currentTime.textColor = defaultColor;
        _currentTime.text = defaultText;
        _currentTime.textAlignment = NSTextAlignmentCenter;


        //progress
        _progressSlider = UISlider.new;
        //正常状态 滑块样式
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        view.backgroundColor = UIColor.grayColor;
        [_progressSlider setThumbImage:[self getImageFromView:view] forState:UIControlStateNormal];

        //拖动下 滑块样式
        view.frame = CGRectMake(0, 0, 16, 16);
        view.backgroundColor = MainColor;
        [_progressSlider setThumbImage:[self getImageFromView:view] forState:UIControlStateHighlighted];


        //总时长
        _durationTime = UILabel.new;
        _durationTime.textColor = defaultColor;
        _durationTime.font = defaultFont;
        _durationTime.text = defaultText;
        _durationTime.textAlignment = NSTextAlignmentCenter;


        //添加
        [self addSubview:_currentTime];
        [self addSubview:_progressSlider];
        [self addSubview:_durationTime];

       // [self layout];
    }
    return self;
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
    [super layoutSubviews];

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self layout];
    });

}

-(void)layout{
    __weak typeof(self) weakSelf = self;
    CGFloat height = CGRectGetHeight(self.bounds);
    [self.currentTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.mas_top);
        make.left.mas_equalTo(weakSelf.mas_left);
        make.size.mas_equalTo(CGSizeMake(height,height));
    }];

    [self.progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.mas_top);
        make.left.mas_equalTo(weakSelf.currentTime.mas_right);
        CGFloat w = CGRectGetWidth(weakSelf.bounds) - height*2;
        make.size.mas_equalTo(CGSizeMake(w, height));
    }];

    [self.durationTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.mas_top);
        make.right.mas_equalTo(weakSelf.mas_right);
        make.size.mas_equalTo(CGSizeMake(height, height));
    }];
}

@end
