//
//  DetailViewController.h
//  MMusic
//
//  Created by Magician on 2018/3/9.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Album;
@class Playlist;

@interface DetailViewController : UIViewController

@property(nonatomic, strong) Album *album;
@property(nonatomic, strong) Playlist *playlist;

-(instancetype)initWithAlbum:(Album*)album;
-(instancetype)initWithPlaylist:(Playlist*) playlist;
/**直接通过专辑,或者播放列表初始化*/
-(instancetype)initWithObject:(id) object;

@end
