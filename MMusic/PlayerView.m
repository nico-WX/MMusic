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
#import <VBFPopFlatButton.h>

@interface PlayerView()
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
- (instancetype)init{
    if (self = [super init]) {
        [self setupSubview];
    }
    return self;
}
-(void)drawRect:(CGRect)rect{
    self.backgroundColor = UIColor.whiteColor;

}
//添加子控件
- (void) setupSubview{
    [self setBackgroundColor:UIColor.whiteColor];

    //辅助层
    _midView = ({
        UIView *view = UIView.new;
        [view.layer setMasksToBounds:NO];
        [view.layer setCornerRadius:8.0f];
        view.layer.shadowColor = UIColor.blackColor.CGColor;
        view.layer.shadowOffset = CGSizeMake(8.0f, 8.0f);
        view.layer.shadowRadius = 5;

        view.backgroundColor = UIColor.grayColor;
        [self addSubview:view];

        view;
    });
    //artwork
    _artworkView = ({
        UIImageView *imageView = UIImageView.new;
        imageView.layer.cornerRadius = 8.0f;
        //imageView.layer.masksToBounds = YES;
        imageView.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];

        [_midView addSubview:imageView];
        imageView;
    });

    //播放进度 及时长
    _progressView = PlayProgressView.new;
    [self addSubview:_progressView];

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
    _playCtrView = PlayControllerView.new;
    [self addSubview:self.playCtrView];

    //喜欢按钮
    _heartIcon = [LOTAnimatedSwitch switchNamed:@"TwitterHeart"];
    [self insertSubview:_heartIcon belowSubview:_playCtrView];
    //[self addSubview:_heartIcon];
    
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
    _midView.layer.shadowColor = UIColor.blackColor.CGColor;
    _midView.layer.shadowOffset = CGSizeMake(100, 100);
    _midView.layer.shadowRadius = 5;

    [self.artworkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(_midView).insets(UIEdgeInsetsMake(2, 2, 2, 2));
    }];


    //进度
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.artworkView.mas_bottom).offset(10);
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
