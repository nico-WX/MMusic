//
//  ChartsCell.h
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/16.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Chart.h"
NS_ASSUME_NONNULL_BEGIN


@interface ChartsCell : UITableViewCell
@property(nonatomic, strong) Chart *chart;
@property(nonatomic, strong, readonly) UICollectionView *collectionView;
@property(nonatomic, strong, readonly) UIButton *showAllButton;
@end

NS_ASSUME_NONNULL_END
