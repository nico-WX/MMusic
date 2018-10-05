//
//  ResourceCell_V2.h
//  MMusic
//
//  Created by 🐙怪兽 on 2018/10/3.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Album.h"
#import "Playlist.h"

NS_ASSUME_NONNULL_BEGIN

@interface ResourceCell_V2 : UICollectionViewCell
@property(nonatomic, strong,readonly) UIImageView    *imageView;
@property(nonatomic, strong,readonly) UILabel        *titleLabel;


@property(nonatomic, strong) Album      *album;
@property(nonatomic, strong) Playlist   *playlists;
@end

NS_ASSUME_NONNULL_END
