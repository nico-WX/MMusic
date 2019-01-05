//
//  MMPlayerButton.h
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/5.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MMPlayerButtonStyle) {
    MMPlayerButtonPreviousStyle,
    MMPlayerButtonPlayStyle,
    MMPlayerButtonPauseStyle,
    MMPlayerButtonStopStyle,
    MMPlayerButtonNextStyle
};

@interface MMPlayerButton : UIControl
@property(nonatomic, assign)MMPlayerButtonStyle style;

+ (instancetype)playerButtonWithStyle:(MMPlayerButtonStyle)style;
- (instancetype)initWithButtonStyle:(MMPlayerButtonStyle)style;

@end

NS_ASSUME_NONNULL_END
