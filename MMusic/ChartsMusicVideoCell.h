//
//  MusicVideoCell.h
//  MMusic
//
//  Created by Magician on 2018/4/6.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChartsMusicVideoCell : UICollectionViewCell
/**MV标签*/
@property(nonatomic, strong) UILabel *titleLabel;
/**艺人名称*/
@property(nonatomic, strong) UILabel *artistLabel;
/**海报*/
@property(nonatomic, strong) UIImageView *artworkView;
@end
