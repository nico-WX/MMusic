//
//  Player.h
//  MMusic
//
//  Created by Magician on 2018/6/27.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <NAKPlaybackIndicatorView.h>
#import "Song.h"

@interface Player : UIViewController
/**当前播放状态*/
@property(nonatomic, strong) void(^playState)(NAKPlaybackIndicatorViewState state);
/**当前播放Item*/
@property(nonatomic, strong) void(^nowPlayingItem)(MPMediaItem *mediaItem);
/**当前播放的song*/
@property(nonatomic, strong) void(^nowPlayingSong)(Song *song);

/**播放songs*/
-(void)playSongs:(NSArray<Song*>*) songs startIndex:(NSUInteger) startIndex;
/**插入歌曲下一首播放*/
-(void)insertSongAtNextItem:(Song*) song;
/**插入播放列表最后播放*/
-(void)insertSongAtEndItem:(Song *) song;

/**跳转到Music App 播放MV*/
-(void)playMusicVideos:(NSArray<MusicVideo*>*)mvs startIndex:(NSUInteger) startIndex;
@end
