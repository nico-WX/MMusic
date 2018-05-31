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
//播放状态指示器
@property(nonatomic, strong, readonly) NAKPlaybackIndicatorView *playbackIndicatorView;

/**播放器*/
@property(nonatomic, strong) MPMusicPlayerController *playerController;
/**正在播放的歌曲*/
@property(nonatomic, strong) Song *nowPlaySong;
/**向外传递正在播放的Item*/
@property(nonatomic, strong) void(^nowPlayingItem)(MPMediaItem *item);
/**单例*/
+(instancetype)sharePlayerViewController;
/**显示播放控制器*/
-(void)showFromViewController:(UIViewController *)vc withSongs:(NSArray<Song*>*) songs startItem:(Song*)startSong;

-(instancetype)initWithTrackArray:(NSArray<Song*>*) trackArray startIndex:(NSUInteger) startIndex;

@end
