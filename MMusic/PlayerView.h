//
//  PlayerView.h
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

@interface PlayerView : UIView
@property(nonatomic, strong, readonly)UIImageView *imageView;
@property(nonatomic, strong, readonly)PlayProgressView *playProgressView;
@property(nonatomic, strong, readonly)UILabel *nameLabel;
@property(nonatomic, strong, readonly)UILabel *artistLabel;
@property(nonatomic, strong, readonly)MMPlayerButton *previous;
@property(nonatomic, strong, readonly)MMPlayerButton *play;
@property(nonatomic, strong, readonly)MMPlayerButton *next;
@property(nonatomic, strong, readonly)MMHeartSwitch *heartSwitch;
@property(nonatomic, strong, readonly)UIButton *shareButton;

@end

NS_ASSUME_NONNULL_END
