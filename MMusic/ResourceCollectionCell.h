//
//  ResourceCollectionCell.h
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/17.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Resource;
@class MPMediaItem;
@class SongManageObject;

NS_ASSUME_NONNULL_BEGIN

@interface ResourceCollectionCell : UICollectionViewCell
@property(nonatomic, strong, readonly) UIImageView *imageView;
@property(nonatomic, strong, readonly) UILabel *titleLabel;
@property(nonatomic, strong, readonly) UILabel *subTitleLable;

@property(nonatomic, strong) Resource *resource;
@property(nonatomic, strong) MPMediaItem *mediaItem;
@property(nonatomic, strong) SongManageObject *songManageObject;
@end

NS_ASSUME_NONNULL_END
