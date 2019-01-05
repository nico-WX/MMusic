//
//  MMPlayerView.h
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/5.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MMHeartSwitch;
@class MMPlayerButton;
@class PlayProgressView;
NS_ASSUME_NONNULL_BEGIN

@interface MMPlayerView : UIView
@property(nonatomic, strong)UIImageView *imageView;
@property(nonatomic, strong)PlayProgressView *playProgressView;
@property(nonatomic, strong)UILabel *nameLabel;
@property(nonatomic, strong)UILabel *artistLabel;
@property(nonatomic, strong)MMPlayerButton *previous;
@property(nonatomic, strong)MMPlayerButton *play;
@property(nonatomic, strong)MMPlayerButton *next;
@property(nonatomic, strong)MMHeartSwitch *heartSwitch;

@end

NS_ASSUME_NONNULL_END
