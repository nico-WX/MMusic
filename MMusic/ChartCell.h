//
//  ChartCell.h
//  MMusic
//
//  Created by 🐙怪兽 on 2018/10/25.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class Chart;
@interface ChartCell : UICollectionViewCell
/**cell 内部的控制器需要压栈, 传入chartsSubVC mainNavigationController*/
@property(nonatomic, weak) UINavigationController *navigationController;
@property(nonatomic, strong) Chart *chart;
@end

NS_ASSUME_NONNULL_END
