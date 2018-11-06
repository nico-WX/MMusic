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

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        //[self setupSubview];

        [self setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0]];
        UIColor *defaultColor = UIColor.grayColor;
        UIFont  *defaultFont = [UIFont systemFontOfSize:12.0f];
        NSString *defaultText = @"00:00";

        //init
        _currentTime = UILabel.new;
        _durationTime = UILabel.new;
        _progressSlider = UISlider.new;

        //label set
        _currentTime.font       = _durationTime.font        = defaultFont;
        _currentTime.textColor  = _durationTime.textColor   = defaultColor;
        _currentTime.text       = _durationTime.text        = defaultText;
        _currentTime.textAlignment = _durationTime.textAlignment = NSTextAlignmentCenter;

        //progress set
        {
            [_progressSlider addTarget:self action:@selector(sliderChange:) forControlEvents:UIControlEventValueChanged];
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
            view.backgroundColor = UIColor.grayColor;
            [_progressSlider setThumbImage:[self imageFromView:view] forState:UIControlStateNormal];

            //拖动下 滑块样式
            view.frame = CGRectMake(0, 0, 16, 16);
            view.backgroundColor = MainColor;
            [_progressSlider setThumbImage:[self imageFromView:view] forState:UIControlStateHighlighted];
        }

        //添加
        [self addSubview:_currentTime];
        [self addSubview:_progressSlider];
        [self addSubview:_durationTime];

        [self.timer fire];
    }
    return self;
}


/**通过视图产生图片 设置到滑块上 */
- (UIImage *)imageFromView:(UIView*)view {
    //切圆
    view.layer.cornerRadius = CGRectGetHeight(view.bounds)/2;
    view.layer.masksToBounds = YES;

    //转换到相同缩放大小的图片
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];     //图层提交到上下文
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();   //上下文中取回照片
    UIGraphicsEndImageContext();
    return image;
}
- (void)layoutSubviews {

    CGFloat h = CGRectGetHeight(self.bounds);
    CGFloat labelW = h*1.2;

    CGRect currentLabFrame = CGRectMake(0, 0, labelW, h);
    CGRect progressFrame = CGRectMake(CGRectGetMaxX(currentLabFrame), 0, CGRectGetWidth(self.bounds)-(labelW*2), h);
    CGRect durationLabFrame = CGRectMake(CGRectGetMaxX(progressFrame), 0, labelW, h);

    [self.currentTime setFrame:currentLabFrame];
    [self.progressSlider setFrame:progressFrame];
    [self.durationTime setFrame:durationLabFrame];

    [super layoutSubviews];
}

- (NSTimer *)timer {
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
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
- (void)sliderChange:(UISlider*)slider {
    NSTimeInterval duration = MainPlayer.nowPlayingItem.playbackDuration;    //总时长
    NSTimeInterval current = duration * slider.value;                        //拖拽时长
    [MainPlayer setCurrentPlaybackTime:current];
}
@end
