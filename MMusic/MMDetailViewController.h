//
//  MMDetailViewController.h
//  ScrollPage
//
//  Created by 🐙怪兽 on 2018/11/12.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MMDetailViewController;
@class Resource;

//dismiss
@protocol MMDetailViewControllerDelegate <NSObject>

- (void)detailViewControllerDidDismiss:(MMDetailViewController*)detailVC;
@end

@interface MMDetailViewController : UIViewController
@property(nonatomic, weak)id<MMDetailViewControllerDelegate> disMissDelegate;
@property (strong, readonly) UIImageView *imageView;
@property (strong, readonly) UILabel *titleLabel;

- (instancetype) initWithResource:(Resource*)resource;

@end

NS_ASSUME_NONNULL_END
