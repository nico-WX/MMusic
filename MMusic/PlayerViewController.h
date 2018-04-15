//
//  PlayerViewController.h
//  MMusic
//
//  Created by Magician on 2018/3/11.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@class Song;

@interface PlayerViewController : UIViewController

@property(nonatomic, strong) MPMusicPlayerController *playerController;

/**正在播放的歌曲(MPMdiaItem 无法获得专辑)*/
@property(nonatomic, strong) Song *nowPlaySong;
@property(nonatomic, strong) NSArray<Song*> *songs;

/**方向传递正在播放的项目*/
@property(nonatomic, strong) void(^nowPlayingItem)(MPMediaItem *item);

+ (instancetype) sharePlayerViewController;

@end
