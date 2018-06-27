//
//  ResourceCell.h
//  MMusic
//
//  Created by Magician on 2018/6/27.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Album.h"
#import "Playlist.h"

@interface ResourceCell : UICollectionViewCell
@property(nonatomic, strong,readonly) UIImageView    *imageView;
@property(nonatomic, strong,readonly) UILabel        *titleLabel;
@property(nonatomic, strong,readonly) UITextView     *descriptionView;
@property(nonatomic, strong,readonly) UILabel        *infoLabel;

@property(nonatomic, strong) Album      *album;
@property(nonatomic, strong) Playlist   *playlists;

@end
