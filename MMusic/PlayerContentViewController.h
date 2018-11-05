//
//  PlayerContentViewController.h
//  MMusic
//
//  Created by Magician on 2018/3/11.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <NAKPlaybackIndicatorView.h>

@class Song;

//播放控制 及 info 更新  子控件事件拆分在各自的视图中, 信息统一通过MainPlayer 获取
@interface PlayerContentViewController : UIViewController

/**单例*/
+ (instancetype)sharePlayerViewController;

/**播放音乐*/
- (void)playSongs:(NSArray<Song*>*)songs startIndex:(NSUInteger)startIndex;
/**插入歌曲下一首播放*/
- (void)insertSongAtNextItem:(Song*)song;
/**插入播放列表最后播放*/
- (void)insertSongAtEndItem:(Song *)song;
/**跳转到Music App 播放MV*/
- (void)playMusicVideos:(NSArray<MusicVideo*>*)mvs startIndex:(NSUInteger)startIndex;
@end
