//
//  NowPlayingViewController+Layout.m
//  ScrollPage
//
//  Created by 🐙怪兽 on 2018/11/10.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <Masonry.h>
#import <MediaPlayer/MediaPlayer.h>

#import "NowPlayingViewController.h"
#import "NowPlayingViewController+Layout.h"
#import "NowPlayingViewController+UpdateUIState.h"
#import "PlayProgressView.h"
#import "MMHeartSwitch.h"

@implementation NowPlayingViewController (Layout)

- (void)viewDidLayoutSubviews {
    if (CGRectGetHeight(self.view.frame) < 100) {
        [self popStateLayout];
    }else{

        [self poppingStateLayout];
        //打开时, 刷新图片大小,
    }
    [self updateButton];

    [super viewDidLayoutSubviews];
}

- (void)popStateLayout{
    //更改文本对齐
    [self.songNameLabel setTextAlignment:NSTextAlignmentLeft];
    [self.artistLabel setTextAlignment:NSTextAlignmentLeft];


    UIEdgeInsets padding = UIEdgeInsetsMake(4, 4, -4, -4);
    UIView *superView = self.view;
    __weak typeof(self) weakSelf = self;
    CGFloat itemW = CGRectGetHeight(superView.bounds) - (padding.top*2);

    [self.artworkView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superView).offset(padding.top);
        make.left.mas_equalTo(superView).offset(padding.left);
        make.bottom.mas_equalTo(superView).offset(padding.bottom);
        make.width.mas_equalTo(itemW);
    }];

    [self.nextButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        [make setRemoveExisting:YES];
        make.top.mas_equalTo(superView).offset(padding.top);
        make.right.mas_equalTo(superView).offset(padding.right);
        make.bottom.mas_equalTo(superView).offset(padding.bottom);
        make.width.mas_equalTo(itemW);
    }];

    [self.playButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superView).offset(padding.top);
        make.right.mas_equalTo(weakSelf.nextButton.mas_left).offset(padding.right);
        make.bottom.mas_equalTo(superView).offset(padding.bottom);
        make.width.mas_equalTo(itemW);
    }];
    [self.songNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superView).offset(padding.top);
        make.left.mas_equalTo(weakSelf.artworkView.mas_right).offset(padding.left);
        make.right.mas_equalTo(weakSelf.playButton.mas_left).offset(padding.right);
    }];


    [self.artistLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.songNameLabel.mas_bottom);
        make.left.right.mas_equalTo(weakSelf.songNameLabel);
        make.bottom.mas_lessThanOrEqualTo(superView).inset(padding.bottom);
    }];
}

- (void)poppingStateLayout{
    //更改文本对齐
    [self.songNameLabel setTextAlignment:NSTextAlignmentCenter];
    [self.artistLabel setTextAlignment:NSTextAlignmentCenter];

    //边距
    UIEdgeInsets padding = UIEdgeInsetsMake(40, 20, -20, -20);
    UIView *superView = self.view;
    __weak typeof(self) weakSelf = self;

    // artworkView布局 与pop状态下的按钮布局 发生冲突(覆盖), 后面更新约束即可更正;
    //移除 , 消除约束警告
    ({
        [self.playButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            [make setRemoveExisting:YES];
        }];
        [self.nextButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            [make setRemoveExisting:YES];
        }];
    });

    //重新布局
    //NSLog(@"begin layout iamgeView");
    [self.artworkView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superView).offset(padding.top);
        make.left.mas_equalTo(superView).offset(padding.left);
        make.right.mas_equalTo(superView).offset(padding.right);
        CGFloat h = CGRectGetWidth(superView.frame)-(padding.left+(fabs(padding.right)));
        make.height.mas_equalTo(h);
    }];

    [self.playProgressView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.artworkView.mas_bottom).offset(padding.top/3);
        make.left.mas_equalTo(superView).offset(padding.left);
        make.right.mas_equalTo(superView).offset(padding.right);
        make.height.mas_equalTo(40);
    }];

    [self.songNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.playProgressView.mas_bottom).offset(padding.top/3);
        make.left.mas_equalTo(superView).offset(padding.left);
        make.right.mas_equalTo(superView).offset(padding.right);
    }];
    [self.artistLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.songNameLabel.mas_bottom);
        make.left.mas_equalTo(superView).offset(padding.left);
        make.right.mas_equalTo(superView).offset(padding.right);
    }];

    // note  按钮间无间距
    CGFloat offset = padding.left+fabs(padding.right);
    CGFloat w = (CGRectGetWidth(superView.frame)-offset)/3; //button 平均宽度
    CGFloat h = 44.0f;
    CGSize buttonSize = CGSizeMake(w, h);

    [self.previousButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.artistLabel.mas_bottom).offset(padding.top/2);
        make.left.mas_equalTo(superView).offset(padding.left);
        make.size.mas_equalTo(buttonSize);
    }];

    [self.playButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.previousButton.mas_top);
        make.left.mas_equalTo(weakSelf.previousButton.mas_right);
        make.size.mas_equalTo(buttonSize);
    }];
    [self.nextButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.playButton.mas_top);
        make.left.mas_equalTo(weakSelf.playButton.mas_right);
        make.size.mas_equalTo(buttonSize);
    }];

    CGFloat heartW = 30.0f;
    [self.heartSwitch mas_remakeConstraints:^(MASConstraintMaker *make) {
        CGFloat heartOffset = CGRectGetMidX(weakSelf.playButton.frame) - heartW/2; //左边偏移
        make.top.mas_equalTo(weakSelf.playButton.mas_bottom).offset(padding.top/2);
        make.left.mas_equalTo(superView).offset(heartOffset);
        make.size.mas_equalTo(CGSizeMake(heartW, heartW));
    }];
}

- (void)mmTabBarControllerPopupState:(BOOL)popping whitFrame:(CGRect)frame{
    //NSLog(@"delegate method!!");
}
@end
