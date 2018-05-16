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


static const CGFloat corner = 8.0f;
@interface PlayerView()
//歌曲时长 等
@property(nonatomic, strong) PlayProgressView *playProgressView;
//播放控件
@property(nonatomic ,strong) PlayControllerView *playCtrView;
/**设置专辑阴影辅助视图*/
@property(nonatomic, strong) UIView *midView;
@end

@implementation PlayerView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupSubview];
    }
    return self;
}

//添加子控件
- (void) setupSubview{
    [self setBackgroundColor:UIColor.whiteColor];

    //辅助层
    _midView = ({
        UIView *view = UIView.new;
        [view.layer setCornerRadius:corner];
        //默认 0
        [view.layer setShadowOpacity:0.8];
        [view.layer setShadowRadius:corner];
        [view.layer setShadowOffset:CGSizeMake(3, 6)];
        [view.layer setShadowColor:UIColor.grayColor.CGColor];

        [self addSubview:view];
        view;
    });
    //artwork
    _artworkView = ({
        UIImageView *imageView = UIImageView.new;
        imageView.layer.cornerRadius = corner;
        imageView.layer.masksToBounds = YES;
        imageView.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];

        [_midView addSubview:imageView];
        imageView;
    });

    //播放进度 及时长
    _playProgressView = ({
        PlayProgressView *view = PlayProgressView.new;
        _currentTime = view.currentTime;
        _durationTime = view.durationTime;
        _progressView = view.progressSlider;
        [_playCtrView setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0]];

        [self addSubview:view];
        view;
    });


    //歌曲名称
    _songNameLabel = ({
        UILabel *label = [[UILabel alloc] init];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setFont:[UIFont systemFontOfSize:30]];

        [self addSubview:label];
        label;
    });

    //歌手
    _artistLabel = ({
        UILabel *label = [[UILabel alloc] init];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setFont:[UIFont systemFontOfSize:20]];
        [label setTextColor:[UIColor grayColor]];

        [self addSubview:label];
        label;
    });

    //播放控制
    _playCtrView = ({
        PlayControllerView *playCtr = PlayControllerView.new;
        _previous   = playCtr.previous;
        _play       = playCtr.play;
        _next       = playCtr.next;

        [self addSubview:playCtr];
        playCtr;
    });

    //喜欢按钮
    _heartIcon = [LOTAnimatedSwitch switchNamed:@"TwitterHeart"];
    [self insertSubview:_heartIcon belowSubview:_playCtrView];

    //循环按钮
    _repeat = UIButton.new;
    [self addSubview:_repeat];

}

- (void)layoutSubviews{
    UIEdgeInsets padding = UIEdgeInsetsMake(40, 40, 40, 40);
    __weak typeof(self) weakSelf = self;
    //中间层
    [self.midView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.mas_top).with.offset(padding.top);
        make.left.mas_equalTo(weakSelf.mas_left).with.offset(padding.left);
        make.right.mas_equalTo(weakSelf.mas_right).with.offset(-padding.right);
        make.height.mas_equalTo(CGRectGetWidth(weakSelf.bounds)-(padding.left*2));
    }];

    //覆盖在中间层上
    [self.artworkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(_midView).insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];


    //进度
    [self.playProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.artworkView.mas_bottom).offset(20);
        make.left.mas_equalTo(weakSelf.mas_left).with.offset(padding.left);
        make.right.mas_equalTo(weakSelf.mas_right).with.offset(-padding.right);
        make.height.mas_equalTo(@44.0f);
    }];
    //song name
    [self.songNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.playProgressView.mas_bottom).with.offset(0);
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
        make.top.mas_equalTo(weakSelf.artistLabel.mas_bottom).with.offset(padding.top/2);
        make.left.mas_equalTo(weakSelf.mas_left).with.offset(padding.left);
        make.right.mas_equalTo(weakSelf.mas_right).with.offset(-padding.right);
        make.height.mas_equalTo(55);
    }];

    [self.heartIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.playCtrView.play.mas_bottom);
        make.centerX.mas_equalTo(weakSelf.playCtrView.play.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(200,200));
    }];
}
 

@end
