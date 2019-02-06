//
//  ResourceTableCell.h
//  MMusic
//
//  Created by 🐙怪兽 on 2019/2/5.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Resource;

NS_ASSUME_NONNULL_BEGIN

@interface ResourceTableCell : UITableViewCell
@property(nonatomic,strong) UIImageView *artworkView;
@property(nonatomic,strong) UILabel *nameLabel;
@property(nonatomic,strong) UILabel *artistLabel;

@property(nonatomic, strong) Resource *resource;
@end

NS_ASSUME_NONNULL_END
