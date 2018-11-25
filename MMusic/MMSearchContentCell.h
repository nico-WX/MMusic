//
//  MMSearchContentCell.h
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/25.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class Resource;
@interface MMSearchContentCell : UICollectionViewCell
@property(nonatomic, strong)Resource *resource;
@property(nonatomic, strong, readonly)UIImageView *imageView;
@property(nonatomic, strong, readonly)UILabel *titleLabel;
@property(nonatomic, strong, readonly)UILabel *subTitleLabel;

@end

NS_ASSUME_NONNULL_END
