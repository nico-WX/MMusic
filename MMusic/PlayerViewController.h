//
//  PlayerViewController.h
//  MMusic
//
//  Created by Magician on 2018/3/11.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <NAKPlaybackIndicatorView.h>

@class Song;

@interface PlayerViewController : UIViewController
/**播放器*/
@property(nonatomic, strong) MPMusicPlayerController *playerController;
/**单例*/
+(instancetype)sharePlayerViewController;

/**播放音乐*/
-(void)playSongs:(NSArray<Song*>*)songs startIndex:(NSUInteger) startIndex;
/**插入歌曲下一首播放*/
-(void)insertSongAtNextItem:(Song*)song;
/**插入播放列表最后播放*/
-(void)insertSongAtEndItem:(Song *)song;
/**跳转到Music App 播放MV*/
-(void)playMusicVideos:(NSArray<MusicVideo*>*)mvs startIndex:(NSUInteger) startIndex;
@end
