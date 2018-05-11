//
//  PlayControllerView.m
//  MMusic
//
//  Created by Magician on 2018/4/14.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import "PlayControllerView.h"
#import <Masonry.h>
#import <VBFPopFlatButton.h>

@interface PlayControllerView()
//中间辅助层
@property(nonatomic, strong)UIView *preView;
@property(nonatomic, strong)UIView *playView;
@property(nonatomic, strong)UIView *nextView;
@end

@implementation PlayControllerView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColor.whiteColor;
        /**
         1.辅助层直接添加到 self.view中, 平分布局;
         2.按钮添加到辅助层中,居中布局
         */
        //辅助层
        _preView = UIView.new;
        _playView = UIView.new;
        _nextView = UIView.new;

        //按钮
        FlatButtonStyle style = buttonRoundedStyle;
        CGRect rect = CGRectMake(0, 0, 44.0f, 44.0f);
        _previous = [[VBFPopFlatButton alloc] initWithFrame:rect buttonType:buttonRewindType buttonStyle:style animateToInitialState:YES];
        _play     = [[VBFPopFlatButton alloc] initWithFrame:rect buttonType:buttonPausedType buttonStyle:style animateToInitialState:YES];
        _next     = [[VBFPopFlatButton alloc] initWithFrame:rect buttonType:buttonFastForwardType buttonStyle:style animateToInitialState:YES];

        //按钮添加到辅层
        [_preView addSubview:_previous];
        [_playView addSubview:_play];
        [_nextView addSubview:_next];

        //添加辅助层带视图中
        [self addSubview:_preView];
        [self addSubview:_playView];
        [self addSubview:_nextView];

        //按钮颜色
        UIColor *color = [UIColor colorWithHue:0.968 saturation:0.827 brightness:1.000 alpha:1.000] ;
        _previous.tintColor = _play.tintColor = _next.tintColor = color;

    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code

    //平分宽度, 等高
    CGSize size = CGSizeMake(CGRectGetWidth(rect)/3,CGRectGetHeight(rect));
    __weak typeof(self) weakSelf = self;

    //布局中间层
    [self.preView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.mas_top);
        make.left.mas_equalTo(weakSelf.mas_left);
        make.size.mas_equalTo(size);
    }];

    [self.playView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.mas_top);
        make.left.mas_equalTo(weakSelf.preView.mas_right);
        make.size.mas_equalTo(size);
    }];

    [self.nextView  mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.mas_top);
        make.left.mas_equalTo(weakSelf.playView.mas_right);
        make.size.mas_equalTo(size);
    }];

    //按钮布局
    CGSize buttonSize = self.previous.bounds.size;
    [self.previous mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(weakSelf.preView.center);
        make.size.mas_equalTo(buttonSize);
    }];
    [self.play mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(weakSelf.playView.center);
        make.size.mas_equalTo(buttonSize);
    }];
    [self.next mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(weakSelf.nextView.center);
        make.size.mas_equalTo(buttonSize);
    }];
}

@end
