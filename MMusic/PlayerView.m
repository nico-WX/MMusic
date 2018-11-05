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

//统一圆角半径
static const CGFloat corner = 8.0f;
@interface PlayerView()
//播放进度信息
@property(nonatomic, strong) PlayProgressView *playProgressView;
//播放控制视图
@property(nonatomic ,strong) PlayControllerView *playCtrView;
/**设置专辑阴影辅助视图*/
@property(nonatomic, strong) UIView *midView;

@end

@implementation PlayerView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.3]];
        [self setupSubview];
        [self setupLayout];
    }
    return self;
}

//添加子控件
- (void) setupSubview{
    
    //辅助层
    _midView = ({
        UIView *view = UIView.new;
        [view.layer setCornerRadius:corner];

        //默认阴影不透明 = 0 看不见效果
        [view.layer setShadowOpacity:0.9];
        [view.layer setShadowRadius:corner];
        [view.layer setShadowOffset:CGSizeMake(3, 6)];
        [view.layer setShadowColor:UIColor.grayColor.CGColor];
        view;
    });

    //artwork
    _artworkView = ({
        UIImageView *imageView = UIImageView.new;
        imageView.layer.cornerRadius = corner;
        imageView.layer.masksToBounds = YES;
        imageView.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        imageView;
    });

    //播放进度 及时长
    _playProgressView = ({
        PlayProgressView *view = PlayProgressView.new;
        _currentTime = view.currentTime;
        _durationTime = view.durationTime;
        _progressView = view.progressSlider;
        [_playCtrView setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0]];
        view;
    });

    //歌曲名称
    _songNameLabel = ({
        UILabel *label = [[UILabel alloc] init];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setFont:[UIFont systemFontOfSize:30]];
        label;
    });

    //歌手
    _artistLabel = ({
        UILabel *label = [[UILabel alloc] init];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setFont:[UIFont systemFontOfSize:20]];
        [label setTextColor:[UIColor grayColor]];

        label;
    });

    //播放控制
    _playCtrView = ({
        PlayControllerView *playCtr = PlayControllerView.new;
        _previous   = playCtr.previous;
        _play       = playCtr.play;
        _next       = playCtr.next;
        playCtr;
    });

    //红心开关  需要先确认size
    _heartIcon = [[MySwitch alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];


    //add subView
    [self addSubview:_midView];
    [_midView addSubview:_artworkView];

    [self addSubview:_playProgressView];
    [self addSubview:_songNameLabel];
    [self addSubview:_artistLabel];
    [self addSubview:_playCtrView];
    [self addSubview:_heartIcon];

    //循环按钮
    _repeat = UIButton.new;
    [self addSubview:_repeat];

}

-(void)setupLayout{

    //边距
    UIEdgeInsets padding = UIEdgeInsetsMake(40, 40, 40, 40);
    //进度条视图高度
    CGFloat processViewHeight = 44.0f;

    __weak typeof(self) weakSelf = self;
    //中间层
    [_midView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.mas_top).with.offset(padding.top);
        make.left.mas_equalTo(weakSelf.mas_left).with.offset(padding.left);

        CGFloat width = CGRectGetWidth(self.bounds)-(padding.left+padding.right);
        CGFloat height = width;
        make.size.mas_equalTo(CGSizeMake(width, height));
    }];

    //覆盖在中间层上
    [_artworkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf.midView).insets(UIEdgeInsetsZero);
    }];

    //进度
    [_playProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.artworkView.mas_bottom).offset(20);
        make.left.mas_equalTo(weakSelf.mas_left).with.offset(padding.left);
        make.right.mas_equalTo(weakSelf.mas_right).with.offset(-padding.right);
        make.height.mas_equalTo(processViewHeight);
    }];
    //song name
    [_songNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.playProgressView.mas_bottom).with.offset(0);
        make.left.mas_equalTo(weakSelf.mas_left).with.offset(padding.left);
        make.right.mas_equalTo(weakSelf.mas_right).with.offset(-padding.right);
        make.height.mas_equalTo(processViewHeight);
    }];
    //艺人名称
    [_artistLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.songNameLabel.mas_bottom).with.offset(0);
        make.left.mas_equalTo(weakSelf.mas_left).with.offset(padding.left);
        make.right.mas_equalTo(weakSelf.mas_right).with.offset(-padding.right);
        make.height.mas_equalTo(processViewHeight);
    }];
    //控制
    [_playCtrView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.artistLabel.mas_bottom).with.offset(padding.top/2);
        make.left.mas_equalTo(weakSelf.mas_left).with.offset(padding.left);
        make.right.mas_equalTo(weakSelf.mas_right).with.offset(-padding.right);
        make.height.mas_equalTo(54);
    }];

    //红心开关
    [_heartIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.playCtrView.play.mas_bottom).offset(padding.top);
        //对齐X轴中心
        make.centerX.mas_equalTo(weakSelf.playCtrView.play.mas_centerX);
        make.size.mas_equalTo(weakSelf.heartIcon.frame.size);
    }];
}

@end
