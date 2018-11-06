//
//  PopupView.h
//
//  Created by 🐙怪兽 on 2018/11/5.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// 浮动 窗口
@interface PopupView : UIView

@property(nonatomic, strong) UIImageView *imageView;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UIButton *playButton;
@property(nonatomic, strong) UIButton *nextButton;
@end

NS_ASSUME_NONNULL_END
