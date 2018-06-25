//
//  ResourceCollectionViewCell.h
//  MMusic
//
//  Created by Magician on 2018/6/17.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Activities.h"
#import "Album.h"
#import "AppleCurator.h"
#import "Artist.h"
#import "Curator.h"
#import "MusicVideo.h"
#import "Playlist.h"
#import "Song.h"
#import "Station.h"

@interface ResourceCollectionViewCell : UICollectionViewCell

//ui
@property(nonatomic, strong,readonly) UIImageView    *artworkView;
@property(nonatomic, strong,readonly) UILabel        *nameLabel;
@property(nonatomic, strong,readonly) UILabel        *artistLabel;

/*
 1. 一共9种常用于展示内容的资源类型, song资源另外通过tableView 展示, 内部不做处理(设置name, artwork,布局 等)
 2. 通过不同的模型, 改变cell subview 的布局, 统一处理collectionViewCell
 */
//model
//@property(nonatomic, strong) Activities     *activites;
//@property(nonatomic, strong) Album          *album;
//@property(nonatomic, strong) AppleCurator   *appleCurator;
//@property(nonatomic, strong) Artist         *artist;
//@property(nonatomic, strong) Curator        *curator;
//@property(nonatomic, strong) MusicVideo     *musicVideo;
//@property(nonatomic, strong) Playlist       *playlist;
///**设置song 模型无效, song数据通过tableView 展示*/
//@property(nonatomic, strong) Song           *song;
//@property(nonatomic, strong) Station        *station;
@end
