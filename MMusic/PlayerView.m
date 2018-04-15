//
//  PlayerView.m
//  MMusic
//
//  Created by Magician on 2018/3/11.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import "PlayerView.h"
#import "PlayProgressView.h"
#import "PlayControllerView.h"
#import <Masonry.h>

@implementation PlayerView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor whiteColor]];
        [self setupSubview];
    }
    return self;
}
- (instancetype)init{
    if (self = [super init]) {
        self.backgroundColor = UIColor.whiteColor;
        [self setupSubview];
    }
    return self;
}

//添加子控件
- (void) setupSubview{
    //close button
    self.closeButton = ({
        UIButton *button = UIButton.new;
        [button setTitle:@"X" forState:UIControlStateNormal];
        button.backgroundColor = UIColor.grayColor;
        button.alpha = 0.75F;
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.titleLabel.font = [UIFont systemFontOfSize:26.0f];

        [self addSubview:button];
        button;
    });

    //artwork
    self.artworkView = ({
        UIImageView *imageView = UIImageView.new;
        imageView.layer.cornerRadius = 8.0f;
        imageView.layer.masksToBounds = YES;
        imageView.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];

        [self addSubview:imageView];
        imageView;
    });

    //播放进度 及时长
    self.progressView = PlayProgressView.new;
    [self addSubview:self.progressView];

    //歌曲名称
    self.songNameLabel = ({
        UILabel *label = [[UILabel alloc] init];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setFont:[UIFont systemFontOfSize:30]];

        [self addSubview:label];
        label;
    });

    //歌手
    self.artistLabel = ({
        UILabel *label = [[UILabel alloc] init];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setFont:[UIFont systemFontOfSize:20]];
        [label setTextColor:[UIColor grayColor]];

        [self addSubview:label];
        label;
    });

    //播放控制
    self.playCtrView = PlayControllerView.new;
    [self addSubview:self.playCtrView];

    //喜欢按钮
    self.like = UIButton.new;
    [self.like setImage:[UIImage imageNamed:@"love-gray"] forState:UIControlStateNormal];
    [self addSubview:self.like];
    
    //循环按钮
    self.repeat = UIButton.new;
    [self addSubview:self.repeat];

    //关闭按钮 添加到最上层
    [self addSubview:self.closeButton];
}

- (void)layoutSubviews{
    UIEdgeInsets padding = UIEdgeInsetsMake(40, 40, 40, 40);
    __weak typeof(self) weakSelf = self;
    //关闭按钮 >>刚好在封面右上角
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.mas_top).with.offset(padding.top);
        make.right.mas_equalTo(weakSelf.mas_right).with.offset(-padding.right);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    //封面
    [self.artworkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.mas_top).with.offset(padding.top);
        make.left.mas_equalTo(weakSelf.mas_left).with.offset(padding.left);
        make.right.mas_equalTo(weakSelf.mas_right).with.offset(-padding.right);
        make.height.mas_equalTo(CGRectGetWidth(weakSelf.bounds)-(padding.left*2));
    }];
    //进度
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.artworkView.mas_bottom);
        make.left.mas_equalTo(weakSelf.mas_left).with.offset(padding.left);
        make.right.mas_equalTo(weakSelf.mas_right).with.offset(-padding.right);
        make.height.mas_equalTo(@44.0f);
    }];
    //song name
    [self.songNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.progressView.mas_bottom).with.offset(0);
        make.left.mas_equalTo(weakSelf.mas_left).with.offset(padding.left);
        make.right.mas_equalTo(weakSelf.mas_right).with.offset(-padding.right);
        make.height.mas_equalTo(@44.0f);
    }];
    //艺人名称
    [self.artistLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.songNameLabel.mas_bottom).with.offset(0);
        make.left.mas_equalTo(weakSelf.mas_left).with.offset(padding.left);
        make.right.mas_equalTo(weakSelf.mas_right).with.offset(-padding.right);
        make.height.mas_equalTo(@44.0f);
    }];
    //控制
    [self.playCtrView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.artistLabel.mas_bottom).with.offset(padding.top);
        make.left.mas_equalTo(weakSelf.mas_left).with.offset(padding.left);
        make.right.mas_equalTo(weakSelf.mas_right).with.offset(-padding.right);
        make.height.mas_equalTo(66);
    }];
}

- (void)drawRect:(CGRect)rect{
    //关闭按钮圆形
    self.closeButton.layer.cornerRadius = CGRectGetHeight(self.closeButton.bounds)/2;
    self.closeButton.layer.masksToBounds = YES;
}

@end
