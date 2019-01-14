//
//  MPMusicPlayerController+ResourcePlaying.h
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/6.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>



@class Song,MusicVideo;

// 播放资源模型对象功能
@interface MPMusicPlayerController (ResourcePlaying)
//以下属性通过联合实现
@property(nonatomic, readonly)NSArray<Song*> *songLists;
@property(nonatomic, readonly)NSArray<MusicVideo*> *musicVideos;


/**当前播放的歌曲对象,可能是异步返回的*/
- (void)nowPlayingSong:(void(^)( Song  * _Nullable song))completion;
/**播放音乐, 并设置起始播放音乐*/
- (void)playSongs:(NSArray<Song*>*)songs startIndex:(NSUInteger)startIndex;
/**下一首播放*/
- (void)insertSongAtNextItem:(Song*)song;
/**播放列表最后播放*/
- (void)insertSongAtEndItem:(Song *)song;

/**播放MV*/
- (void)playMusicVideos:(NSArray<MusicVideo*>*)mvs startIndex:(NSUInteger)startIndex;
@end
