//
//  MMSearchContentViewController.h
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/25.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class ResponseRoot;
@interface MMSearchContentViewController : UIViewController
@property(nonatomic, strong,readonly) ResponseRoot *responseRoot;
- (instancetype)initWithResponseRoot:(ResponseRoot*)responseRoot;
@end

NS_ASSUME_NONNULL_END
