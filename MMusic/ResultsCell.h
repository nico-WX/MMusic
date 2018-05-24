//
//  ResultsCell.h
//  MMusic
//
//  Created by Magician on 2018/5/22.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Resource.h"

@interface ResultsCell : UITableViewCell
@property(nonatomic, assign, readonly) UIEdgeInsets padding;
@property(nonatomic, strong, readonly) UIImageView *artworkView;
@property(nonatomic, strong, readonly) UILabel *nameLabel;
@property(nonatomic, strong, readonly) UILabel *artistLabel;
@property(nonatomic, strong, readonly) UILabel *descLabel;
@property(nonatomic, strong) Resource *resource;
@end
