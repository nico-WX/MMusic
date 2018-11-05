//
//  PlayProgressView.m
//  MMusic
//
//  Created by Magician on 2018/4/14.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import "PlayProgressView.h"
#import <MediaPlayer/MediaPlayer.h>
#import <Masonry.h>

@interface PlayProgressView()
@property(nonatomic, strong) NSTimer *timer;
@end

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
        [_progressSlider addTarget:self action:@selector(sliderChange:) forControlEvents:UIControlEventValueChanged];
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

        [self.timer fire];
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

    CGFloat h = CGRectGetHeight(self.bounds);
    CGFloat labelW = h*1.5;

    CGRect currentLabFrame = CGRectMake(0, 0, labelW, h);
    CGRect progressFrame = CGRectMake(CGRectGetMaxX(currentLabFrame), 0, CGRectGetWidth(self.bounds)-(labelW*2), h);
    CGRect durationLabFrame = CGRectMake(CGRectGetMaxX(progressFrame), 0, labelW, h);

    [self.currentTime setFrame:currentLabFrame];
    [self.progressSlider setFrame:progressFrame];
    [self.durationTime setFrame:durationLabFrame];

    [super layoutSubviews];
}

- (NSTimer *)timer{
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:2.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
            NSTimeInterval current = (CGFloat)MainPlayer.currentPlaybackTime;
            NSTimeInterval duration = MainPlayer.nowPlayingItem.playbackDuration; //秒

            self.currentTime.text = [NSString stringWithFormat:@"%.2d:%.2d",((int)current)/60,((int)current)%60];
            //更新进度条
            CGFloat value = (current/duration);
            [self.progressSlider setValue:value animated:YES];
            [self.durationTime setText:[NSString stringWithFormat:@"%.2d:%.2d",((int)duration)/60,((int)duration)%60]];
        }];
    }
    return _timer;
}

    //进度条拖拽事件
- (void)sliderChange:(UISlider*) slider{
    NSTimeInterval duration = MainPlayer.nowPlayingItem.playbackDuration;    //总时长
    NSTimeInterval current = duration * slider.value;                        //拖拽时长
    [MainPlayer setCurrentPlaybackTime:current];
}
@end
