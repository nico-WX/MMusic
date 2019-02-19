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

@interface MPMusicPlayerController()
/**播放队列*/
@property(nonatomic, strong)MPMusicPlayerPlayParametersQueueDescriptor *parametersQueue;
@end

@implementation MPMusicPlayerController (ResourcePlaying)

#pragma mark - foundation method
- (void)playSongs:(NSArray<Song*> *)songs startIndex:(NSUInteger)startIndex{
    [self setSongLists:songs];
    //歌单生成播放队列
    self.parametersQueue = [self playParametersQueueFromSongs:songs startPlayIndex:startIndex];

    // 开始的歌曲 与当前需要播放歌曲相同, 不执行操作;
    Song *song = [self.songLists objectAtIndex:startIndex];
    if (![song isEqualToMediaItem:self.nowPlayingItem]) {
        [self setQueueWithDescriptor:self.parametersQueue];
        [self play];
        [self prepareToPlayWithCompletionHandler:^(NSError * _Nullable error) {

        }];
    }else{
        //暂停, 继续
        switch (self.playbackState) {
            case MPMusicPlaybackStatePaused:
                [self play];
                break;
            case MPMusicPlaybackStatePlaying:
                [self pause];

            default:
                break;
        }
    }



}
- (void)insertSongAtEndItem:(Song *)song {
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.songLists];
    //[array addObjectsFromArray:self.songLists];
    [array addObject:song];
    self.songLists = array;

    //添加到当前播放队列后面
    MPMusicPlayerPlayParameters *prameters = [[MPMusicPlayerPlayParameters alloc] initWithDictionary:song.playParams];
    MPMusicPlayerPlayParametersQueueDescriptor *queue;
    queue = [[MPMusicPlayerPlayParametersQueueDescriptor alloc] initWithPlayParametersQueue:@[prameters,]];
    [self appendQueueDescriptor:queue];
}

- (void)insertSongAtNextItem:(Song *)song {

    NSUInteger index = [self indexOfNowPlayingItem];
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.songLists];
    //[array addObject:self.songLists];
    [array insertObject:song atIndex:index+1];
    self.songLists = array;

    //添加到当前播放Item 后面
    MPMusicPlayerPlayParameters *prameters = [[MPMusicPlayerPlayParameters alloc] initWithDictionary:song.playParams];
    MPMusicPlayerPlayParametersQueueDescriptor *queue;
    queue = [[MPMusicPlayerPlayParametersQueueDescriptor alloc] initWithPlayParametersQueue:@[prameters,]];
    [self prependQueueDescriptor:queue];
}

- (void)nowPlayingSong:(void (^)(Song * _Nullable))completion{

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_apply(self.songLists.count, queue, ^(size_t i) {
        Song *song = [self.songLists objectAtIndex:i];
        if ([song isEqualToMediaItem:self.nowPlayingItem]) {
            mainDispatch(^{
                completion(song);
            });
            return ;
        }
    });

    NSString *identifier = self.nowPlayingItem.playbackStoreID;
    // "0"标识数据库无此歌曲]
    if (identifier.length > 2) {
        //异步加载
        [MusicKit.new.catalog resources:@[identifier,] byType:CatalogSongs callBack:^(NSDictionary *json, NSHTTPURLResponse *response) {
            if (json) {
                json = [(NSArray*)[json valueForKey:@"data"] firstObject] ;
                mainDispatch(^{
                    completion([Song instanceWithDict:json]);
                });
            }else{
                //无数据 404 等
                completion(NULL);
            }
        }];
    }else{
        completion(NULL);
    }
}


- (void)playMusicVideos:(NSArray<MusicVideo*> *)mvs startIndex:(NSUInteger)startIndex{
    [self setMusicVideos:mvs];
    NSMutableArray<MPMusicPlayerPlayParameters*> *array = [NSMutableArray array];
    for (MusicVideo *mv in mvs) {
        [array addObject:[[MPMusicPlayerPlayParameters alloc] initWithDictionary:mv.playParams]];
    }
    MPMusicPlayerPlayParametersQueueDescriptor *queue = [[MPMusicPlayerPlayParametersQueueDescriptor alloc] initWithPlayParametersQueue:array];
    [queue setStartItemPlayParameters:[array objectAtIndex:startIndex]];
    [MainPlayer openToPlayQueueDescriptor:queue];
}

#pragma mark - help
- (MPMusicPlayerPlayParametersQueueDescriptor*)playParametersQueueFromSongs:(NSArray<Song*>*)songs
                                                              startPlayIndex:(NSUInteger)index {
    NSMutableArray<MPMusicPlayerPlayParameters*> *list = [NSMutableArray array];
    for (Song *song in songs) {
        [list addObject:[[MPMusicPlayerPlayParameters alloc] initWithDictionary:song.playParams]];
    }
    MPMusicPlayerPlayParametersQueueDescriptor *queue;
    queue = [[MPMusicPlayerPlayParametersQueueDescriptor alloc] initWithPlayParametersQueue:list];
    [queue setStartItemPlayParameters:[list objectAtIndex:index]];
    return queue;
}



#pragma mark - 关联属性对象
// song
- (void)setSongLists:(NSArray<Song *> *)songLists{
    objc_setAssociatedObject(self, @selector(songLists), songLists, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSArray<Song *> *)songLists {
    return objc_getAssociatedObject(self, _cmd);
}

//MV
- (void)setMusicVideos:(NSArray<MusicVideo *> *)musicVideos {
    objc_setAssociatedObject(self, @selector(musicVideos), musicVideos, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSArray<MusicVideo *> *)musicVideos{
    return objc_getAssociatedObject(self, _cmd);
}

//queue
- (void)setParametersQueue:(MPMusicPlayerPlayParametersQueueDescriptor *)parametersQueue{
    objc_setAssociatedObject(self, @selector(parametersQueue), parametersQueue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (MPMusicPlayerPlayParametersQueueDescriptor *)parametersQueue{
    return objc_getAssociatedObject(self, _cmd);
}

@end
