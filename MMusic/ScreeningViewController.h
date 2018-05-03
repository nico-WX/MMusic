//
//  ScreeningViewController.h
//  MMusic
//
//  Created by Magician on 2018/4/26.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ScreeningViewControllerDelegate

@required

@end

@interface ScreeningViewController : UIViewController
@property(nonatomic, strong) UICollectionView *collectionView;
@end
