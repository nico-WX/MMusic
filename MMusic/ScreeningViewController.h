//
//  ScreeningViewController.h
//  MMusic
//
//  Created by Magician on 2018/4/26.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScreeningViewController : UIViewController
//分类内容
@property(nonatomic, strong,readonly) UICollectionView *collectionView;
/**选中的分类*/
@property(nonatomic, strong) void(^selectedItem)(NSString* text);

@end
