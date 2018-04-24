//
//  ChartsCell.h
//  MMusic
//
//  Created by Magician on 2018/4/24.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChartsCell : UICollectionViewCell
/**封面*/
@property(nonatomic, strong) UIImageView *artworkView;
/**名称*/
@property(nonatomic, strong) UILabel     *titleLabel;
/**艺人 或主题*/
@end
