//
//  MMPlayerButton.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/5.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "MMPlayerButton.h"
#import "ButtonStyleKit.h"

@implementation MMPlayerButton

+ (instancetype)playerButtonWithStyle:(MMPlayerButtonStyle)style{
    return [[self alloc] initWithButtonStyle:style];
}

- (instancetype)initWithButtonStyle:(MMPlayerButtonStyle)style{
    if (self = [super initWithFrame:CGRectZero]) {
        _style = style;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code

    ButtonStyleKitResizingBehavior resizing = ButtonStyleKitResizingBehaviorAspectFit;
    switch (self.style) {
        case MMPlayerButtonPreviousStyle:{
            [ButtonStyleKit drawPreviousButtonWithFrame:rect resizing:resizing];
        }
            break;
        case MMPlayerButtonPlayStyle:{
            [ButtonStyleKit drawPlayButtonWithFrame:rect resizing:resizing];
        }
            break;
        case MMPlayerButtonPauseStyle:{
            [ButtonStyleKit drawPauseButtonWithFrame:rect resizing:resizing];
        }
            break;
        case MMPlayerButtonStopStyle:{
            [ButtonStyleKit drawStopButtonWithFrame:rect resizing:resizing];
        }
            break;
        case MMPlayerButtonNextStyle:{
            [ButtonStyleKit drawNextButtonWithFrame:rect resizing:resizing];
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

@end
