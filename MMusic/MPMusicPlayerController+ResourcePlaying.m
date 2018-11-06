//
//  MPMusicPlayerController+ResourcePlaying.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/6.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <objc/runtime.h>
#import "MPMusicPlayerController+ResourcePlaying.h"

#import "Song.h"
#import "MusicVideo.h"

@interface MPMusicPlayerController()<MPSystemMusicPlayerController>
@property(nonatomic, strong)NSArray<Song*> *songLists;
@property(nonatomic, strong)NSArray<MusicVideo*> *musicVideos;
@property(nonatomic, strong)MPMusicPlayerPlayParametersQueueDescriptor *parametersQueue;
@end

@implementation MPMusicPlayerController (ResourcePlaying)


#pragma mark - play song method
- (void)playSongs:(NSArray<Song*> *)songs startIndex:(NSUInteger)startIndex{
    [self setSongLists:songs];
    self.parametersQueue = [self playParametersQueueFromSongs:songs startPlayIndex:startIndex];

    // 开始的歌曲 与当前歌曲相同, 不播放
    Song *song = [self.songLists objectAtIndex:startIndex];
    if (![song isEqualToMediaItem:self.nowPlayingItem]) {
        [self setQueueWithDescriptor:self.parametersQueue];
        [self play];
    }
}
- (void)insertSongAtEndItem:(Song *)song {
    NSMutableArray *array = [NSMutableArray array];
    [array addObjectsFromArray:self.songLists];
    [array addObject:song];
    self.songLists = array;

    //添加到当前播放item 后面
    MPMusicPlayerPlayParameters *prameters = [[MPMusicPlayerPlayParameters alloc] initWithDictionary:song.playParams];
    MPMusicPlayerPlayParametersQueueDescriptor *queue;
    queue = [[MPMusicPlayerPlayParametersQueueDescriptor alloc] initWithPlayParametersQueue:@[prameters,]];
    [self appendQueueDescriptor:queue];
}

- (void)insertSongAtNextItem:(Song *)song {

    NSUInteger index = [self indexOfNowPlayingItem];
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:self.songLists];
    [array insertObject:song atIndex:index+1];
    self.songLists = array;

    //添加到最后
    MPMusicPlayerPlayParameters *prameters = [[MPMusicPlayerPlayParameters alloc] initWithDictionary:song.playParams];
    MPMusicPlayerPlayParametersQueueDescriptor *queue;
    queue = [[MPMusicPlayerPlayParametersQueueDescriptor alloc] initWithPlayParametersQueue:@[prameters,]];
    [self prependQueueDescriptor:queue];
}

- (Song *)nowPlaySong{
    Song *nowSong;
    for (Song *song in self.songLists) {
        if ([song isEqualToMediaItem:self.nowPlayingItem]) {
            nowSong = song;
        }
    }
    return nowSong;
}

#pragma mark play mv
- (void)playMusicVideos:(NSArray<MusicVideo *> *)mvs startIndex:(NSUInteger)startIndex{
    NSMutableArray<MPMusicPlayerPlayParameters*> *array = [NSMutableArray array];
    for (MusicVideo *mv in mvs) {
        [array addObject:[[MPMusicPlayerPlayParameters alloc] initWithDictionary:mv.playParams]];
    }
    MPMusicPlayerPlayParametersQueueDescriptor *queue = [[MPMusicPlayerPlayParametersQueueDescriptor alloc] initWithPlayParametersQueue:array];
    [queue setStartItemPlayParameters:[array objectAtIndex:startIndex]];
    [self openToPlayQueueDescriptor:queue];
}

#pragma mark - MPSystemMusicPlayerController
-(void)openToPlayQueueDescriptor:(MPMusicPlayerQueueDescriptor *)queueDescriptor{
    UIApplication *app = [UIApplication sharedApplication];
    NSURL *url = [NSURL URLWithString:@"Music:prefs:root=MUSIC"];
    if ([app canOpenURL:url]) {
        [app openURL:url options:@{} completionHandler:^(BOOL success) {
            [MainPlayer setQueueWithDescriptor:queueDescriptor];
            [MainPlayer play];
        }];
    }
}


#pragma mark - 关联分类添加的属性对象
- (void)setSongLists:(NSArray<Song *> *)songLists{
    objc_setAssociatedObject(self, @selector(songLists), songLists, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSArray<Song *> *)songLists {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setMusicVideos:(NSArray<MusicVideo *> *)musicVideos {
    objc_setAssociatedObject(self, @selector(musicVideos), musicVideos, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSArray<MusicVideo *> *)musicVideos{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setParametersQueue:(MPMusicPlayerPlayParametersQueueDescriptor *)parametersQueue{
    objc_setAssociatedObject(self, @selector(parametersQueue), parametersQueue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (MPMusicPlayerPlayParametersQueueDescriptor *)parametersQueue{
    return objc_getAssociatedObject(self, _cmd);
}
@end
