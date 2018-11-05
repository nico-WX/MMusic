//
//  MyCell.h
//  蒙版Cell
//
//  Created by 🐙怪兽 on 2018/11/1.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Album,Playlist;
NS_ASSUME_NONNULL_BEGIN

@interface MyCell : UICollectionViewCell
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UIImageView *imageView;

@property(nonatomic, strong) Album      *album;
@property(nonatomic, strong) Playlist   *playlists;
@end

NS_ASSUME_NONNULL_END
