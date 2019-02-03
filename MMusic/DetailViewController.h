//
//  DetailViewController.h
//  ScrollPage
//
//  Created by 🐙怪兽 on 2018/11/12.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class DetailViewController;
@class Resource;

//dismiss
@protocol MMDetailViewControllerDelegate <NSObject>
- (void)detailViewControllerDidDismiss:(DetailViewController*)detailVC;
@end

@interface DetailViewController : UIViewController

@property (nonatomic, weak) id<MMDetailViewControllerDelegate> disMissDelegate;
@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, strong, readonly) UILabel *titleLabel;

- (instancetype) initWithResource:(Resource*)resource;
@end

NS_ASSUME_NONNULL_END
