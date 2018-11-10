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
@class MySwitch;
@interface NowPlayingViewController : UIViewController<MMTabbarControllerPopupDelegate>
@property(nonatomic, strong)UIImageView *artworkView;
@property(nonatomic, strong)PlayProgressView *playProgressView;
@property(nonatomic, strong)UILabel *songNameLabel;
@property(nonatomic, strong)UILabel *artistLabel;
@property(nonatomic, strong)UIButton *previousButton;
@property(nonatomic, strong)UIButton *playButton;
@property(nonatomic, strong)UIButton *nextButton;
@property(nonatomic, strong)MySwitch *heartSwitch;


+ (instancetype)sharePlayerViewController;

@end

NS_ASSUME_NONNULL_END
