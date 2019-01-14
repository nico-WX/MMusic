//
//  MMPlayerButton.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/5.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "MMPlayerButton.h"
#import "ButtonStyleKit.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation MMPlayerButton

+ (instancetype)playerButtonWithStyle:(MMPlayerButtonStyle)style{
    return [[self alloc] initWithButtonStyle:style];
}

- (instancetype)initWithButtonStyle:(MMPlayerButtonStyle)style{
    if (self = [super initWithFrame:CGRectZero]) {
        _style = style;

        [self setBackgroundColor:[UIColor colorWithWhite:1 alpha:0]];

        [self handleControlEvent:UIControlEventTouchUpInside withBlock:^{
            [self animationButton:self];
        }];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code

    ButtonStyleKitResizingBehavior resizing = ButtonStyleKitResizingBehaviorStretch;
    switch (self.style) {
        case MMPlayerButtonPreviousStyle:{
            [ButtonStyleKit drawPreviousCanvasWithFrame:rect resizing:resizing];
        }
            break;
        case MMPlayerButtonPlayStyle:{
            [ButtonStyleKit drawPlayCanvasWithFrame:rect resizing:resizing];
        }
            break;
        case MMPlayerButtonPauseStyle:{
            [ButtonStyleKit drawPauseCanvasWithFrame:rect resizing:resizing];
        }
            break;
        case MMPlayerButtonStopStyle:{
            [ButtonStyleKit drawStopCanvasWithFrame:rect resizing:resizing];
        }
            break;
        case MMPlayerButtonNextStyle:{
            [ButtonStyleKit drawNextCanvasWithFrame:rect resizing:resizing];
        }
            break;
    }
}

- (void)setStyle:(MMPlayerButtonStyle)style{
    if (_style != style) {
        _style = style;
        [self setNeedsDisplay];
    }
}


- (void)animationButton:(UIView*)sender{
    [UIView animateWithDuration:0.2 animations:^{
        [sender setTransform:CGAffineTransformMakeScale(0.88, 0.88)];
    } completion:^(BOOL finished) {
        //恢复
        [UIView animateWithDuration:0.2 animations:^{
            [sender setTransform:CGAffineTransformIdentity];
        }];
    }];
}



@end
