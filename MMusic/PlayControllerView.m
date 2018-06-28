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
         1.辅助层直接添加到 self中, 平分布局;
         2.按钮添加到辅助层中,居中布局
         */
        //辅助层
        _preView = UIView.new;
        _playView = UIView.new;
        _nextView = UIView.new;

        //按钮
        _previous   = [[UIButton alloc] init];
        _play       = [[UIButton alloc] init];
        _next       = [[UIButton alloc] init];

        //添加辅助层带视图中
        [self addSubview:_preView];
        [self addSubview:_playView];
        [self addSubview:_nextView];

        //按钮添加到辅层
        [_preView addSubview:_previous];
        [_playView addSubview:_play];
        [_nextView addSubview:_next];

        //按钮颜色
        _previous.tintColor = _play.tintColor = _next.tintColor = MainColor;

    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code

    //平分宽度, 等高
    CGFloat w = CGRectGetWidth(rect)/3;
    __weak typeof(self) weakSelf = self;

    //布局中间层
    [self.preView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.mas_top);
        make.left.mas_equalTo(weakSelf.mas_left);
        make.bottom.mas_equalTo(weakSelf.mas_bottom);
        make.width.mas_equalTo(w);
    }];

    [self.playView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.mas_top);
        make.left.mas_equalTo(weakSelf.preView.mas_right);
        make.bottom.mas_equalTo(weakSelf.mas_bottom);
        make.width.mas_equalTo(w);
    }];

    [self.nextView  mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.mas_top);
        make.left.mas_equalTo(weakSelf.playView.mas_right);
        make.bottom.mas_equalTo(weakSelf.mas_bottom);
        make.right.mas_equalTo(weakSelf.mas_right);
    }];


    CGFloat btnH = CGRectGetHeight(self.frame);
    CGFloat btnW = btnH;
    CGSize size = CGSizeMake(btnW, btnH);

    [self.previous mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(size);
        make.center.mas_equalTo(weakSelf.preView.center);
    }];

    [self.play mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(size);
        make.center.mas_equalTo(weakSelf.playView.center);
    }];

    [self.next mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(size);
        make.center.mas_equalTo(weakSelf.nextView.center);
    }];


    //按钮 image
    [_previous setImage:[UIImage imageNamed:@"rewind"] forState:UIControlStateNormal];
    [_play setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    [_next setImage:[UIImage imageNamed:@"forward"] forState:UIControlStateNormal];

    [_previous setTitleColor:MainColor forState:UIControlStateNormal];
}

////图片宽高比
//-(CGFloat) aspectRatioWithImage:(UIImage*) image{
//    return image.size.width/image.size.height;
//}

@end
