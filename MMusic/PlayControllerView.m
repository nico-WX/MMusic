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

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code

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

    //[self.play setFrame:CGRectMake(0, 0,44, 44)];
    Log(@"ra  = %@",NSStringFromCGRect(self.play.bounds));
    self.play.tintColor = UIColor.blueColor;
}


- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColor.whiteColor;

        //辅助层
        self.preView = UIView.new;
        self.playView = UIView.new;
        self.nextView = UIView.new;

        //按钮
        FlatButtonStyle style = buttonRoundedStyle;
        CGRect rect = CGRectMake(0, 0, 44.0f, 44.0f);
        self.previous = [[VBFPopFlatButton alloc] initWithFrame:rect buttonType:buttonRewindType buttonStyle:style animateToInitialState:YES];
        self.play     = [[VBFPopFlatButton alloc] initWithFrame:rect buttonType:buttonPausedType buttonStyle:style animateToInitialState:YES];
        self.next     = [[VBFPopFlatButton alloc] initWithFrame:rect buttonType:buttonFastForwardType buttonStyle:style animateToInitialState:YES];

        //按钮添加到辅层
        [self.preView addSubview:self.previous];
        [self.playView addSubview:self.play];
        [self.nextView addSubview:self.next];

        //添加到本身
        [self addSubview:self.preView];
        [self addSubview:self.playView];
        [self addSubview:self.nextView];

        //颜色
        self.previous.tintColor = self.play.tintColor = self.next.tintColor = UIColor.blueColor;
        //bg
//        self.previous.roundBackgroundColor = self.play.roundBackgroundColor = self.next.roundBackgroundColor = UIColor.blueColor;
    }
    return self;
}


@end
