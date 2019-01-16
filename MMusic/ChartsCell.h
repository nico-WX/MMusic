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


@protocol ChartsCellDelegate <NSObject>
@end

@interface ChartsCell : UITableViewCell{
    @private
    
}
@property(nonatomic, strong) Chart *chart;
@property(nonatomic, strong, readonly) UICollectionView *collectionView;
@property(nonatomic, strong, readonly) UIButton *showMoreButton;
@end

NS_ASSUME_NONNULL_END
