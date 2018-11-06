//
//  MPMusicPlayerController+ResourcePlaying.h
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/6.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

NS_ASSUME_NONNULL_BEGIN

@class Song,MusicVideo;

// 增加播放资源对象功能 (从NowPlayingViewController 中剥离这部分功能)
@interface MPMusicPlayerController (ResourcePlaying)
@property(nonatomic, readonly)NSArray<Song*> *songLists;
@property(nonatomic, readonly)NSArray<MusicVideo*> *musicVideos;


/**播放音乐, 并设置起始播放音乐*/
- (void)playSongs:(NSArray<Song*>*)songs startIndex:(NSUInteger)startIndex;
/**下一首播放*/
- (void)insertSongAtNextItem:(Song*)song;
/**播放列表最后播放*/
- (void)insertSongAtEndItem:(Song *)song;
/**当前播放的音乐*/
- (Song*)nowPlayingSong;
/**播放MV*/
- (void)playMusicVideos:(NSArray<MusicVideo*>*)mvs startIndex:(NSUInteger)startIndex;
@end

NS_ASSUME_NONNULL_END
