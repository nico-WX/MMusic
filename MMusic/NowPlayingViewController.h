//
//  RedViewController.h
//  ScrollPage
//
//  Created by 🐙怪兽 on 2018/11/8.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMTabBarController.h"

NS_ASSUME_NONNULL_BEGIN

@class PlayProgressView;
@class MMHeartSwitch;
@interface NowPlayingViewController : UIViewController<MMTabBarControllerPopupStateDelegate>


@property(nonatomic, strong, readonly)UIImageView *artworkView;
@property(nonatomic, strong, readonly)PlayProgressView *playProgressView;
@property(nonatomic, strong, readonly)UILabel *songNameLabel;
@property(nonatomic, strong, readonly)UILabel *artistLabel;
@property(nonatomic, strong, readonly)UIButton *previousButton;
@property(nonatomic, strong, readonly)UIButton *playButton;
@property(nonatomic, strong, readonly)UIButton *nextButton;
@property(nonatomic, strong, readonly)MMHeartSwitch *heartSwitch;

+ (instancetype)sharePlayerViewController;
@end

NS_ASSUME_NONNULL_END
