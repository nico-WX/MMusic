//
//  MMPlayerControlButtonView.h
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/5.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MMPlayerButton;
NS_ASSUME_NONNULL_BEGIN

@interface MMPlayerControlButtonView : UIView
@property(nonatomic, strong) MMPlayerButton *previous;
@property(nonatomic, strong) MMPlayerButton *play;
@property(nonatomic, strong) MMPlayerButton *next;
@end

NS_ASSUME_NONNULL_END
