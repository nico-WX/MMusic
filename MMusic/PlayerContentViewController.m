//
//  PlayerContentViewController.m
//  MMusic
//
//  Created by Magician on 2018/3/11.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <Masonry.h>

#import "PlayerContentViewController.h"
#import "PlayerView.h"

#import "NSObject+Tool.h"
#import "Artwork.h"
#import "Song.h"
#import "MusicVideo.h"

#import "DBTool.h"
#import "TracksModel.h"
#import "ArtistsModel.h"

@interface PlayerContentViewController ()<MPSystemMusicPlayerController>
/**播放器UI*/
@property(nonatomic, strong) PlayerView *playerView;

/**歌曲列表*/
@property(nonatomic, strong) NSArray<Song*> *songs;
/**播放队列*/
@property(nonatomic, strong)MPMusicPlayerPlayParametersQueueDescriptor *parametersQueue;
@end


static PlayerContentViewController *_instance;

@implementation PlayerContentViewController

#pragma mark - 初始化 / 单例
+ (instancetype)sharePlayerViewController{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_instance) {
            _instance = [[self alloc] init];
        }
    });
    return _instance;
}
+(instancetype)allocWithZone:(struct _NSZone *)zone{
    //防止同时访问
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_instance){
            _instance = [super allocWithZone:zone];
        }
    });
    return _instance;
}
-(instancetype)init{
    if (self = [super init]) {
        //不在viewDidLoad 中添加
        [self.view addSubview:self.playerView];
    }
    return self;
}
-(id)copyWithZone:(NSZone *)zone{
    return _instance;
}
-(id)mutableCopyWithZone:(NSZone *)zone{
    return _instance;
}

#pragma mark - cycle
- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self updateCurrentItemMetadata];
}

- (void)dealloc{
    [MainPlayer endGeneratingPlaybackNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];    
}


#pragma mark - 更新UI信息
-(void)updateCurrentItemMetadata{
    MPMediaItem *nowPlayingItem = MainPlayer.nowPlayingItem;
    if (nowPlayingItem) {
        //播放的时候, 有可能在播放第三方音乐, 从而控制喜欢开关是否有效(但4G网络播放未开启时,可能也没有playbackStoreID)
        self.playerView.heartIcon.enabled = nowPlayingItem.playbackStoreID ? YES  : NO;
        [self heartFromSongIdentifier:nowPlayingItem.playbackStoreID];

        [self.playerView.songNameLabel setText:nowPlayingItem.title];
        [self.playerView.artistLabel setText:nowPlayingItem.artist];

        UIImage *image  = [nowPlayingItem.artwork imageWithSize:self.playerView.artworkView.bounds.size];
        if (image) {
            [self.playerView.artworkView setImage:image];
        }else{
            //清除旧数据
            //self.playerView.artworkView.image = nil;
            if (nowPlayingItem.playbackStoreID) {
                [MusicKit.new.api resources:@[nowPlayingItem.playbackStoreID] byType:CatalogSongs callBack:^(NSDictionary *json, NSHTTPURLResponse *response) {
                    json = [[[json valueForKey:@"data"] firstObject] valueForKey:@"attributes"];
                    Song *song = [Song instanceWithDict:json];
                    [self showImageToView:self.playerView.artworkView withImageURL:song.artwork.url cacheToMemory:YES];
                }];
            }else{
                for (Song *song in _songs ) {
                    if ([song isEqualToMediaItem:nowPlayingItem]) {
                        [self showImageToView:self.playerView.artworkView withImageURL:song.artwork.url cacheToMemory:YES];
                    }
                }
            }
        }
    }else{
        [self.playerView.heartIcon setEnabled:NO];
        self.playerView.artworkView.image = nil;
        self.playerView.songNameLabel.text = @"当前无歌曲播放";
        self.playerView.artistLabel.text = @"";
    }

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

#pragma mark - Instance Method
-(void)playSongs:(NSArray<Song *> *)songs startIndex:(NSUInteger)startIndex{
    [self setSongs:songs];

    //当前开始的song 与正在播放的item 是否为同一个
    Song *song = [self.songs objectAtIndex:startIndex];
    if (![song isEqualToMediaItem:MainPlayer.nowPlayingItem]) {
        MPMusicPlayerPlayParameters *parameter = [[MPMusicPlayerPlayParameters alloc] initWithDictionary:song.playParams];
        [self.parametersQueue setStartItemPlayParameters:parameter];
        [MainPlayer setQueueWithDescriptor:self.parametersQueue];
        [MainPlayer play];
    }
}
-(void)insertSongAtNextItem:(Song *)song{
    MPMusicPlayerPlayParameters *parameter = [[MPMusicPlayerPlayParameters alloc] initWithDictionary:song.playParams];
    MPMusicPlayerPlayParametersQueueDescriptor *queue = [[MPMusicPlayerPlayParametersQueueDescriptor alloc] initWithPlayParametersQueue:@[parameter,]];
    [MainPlayer prependQueueDescriptor:queue];

    NSMutableArray<Song*> *array = [NSMutableArray arrayWithArray:self.songs];
    NSUInteger index = MainPlayer.indexOfNowPlayingItem;
    //数据添加到指定位置
    if (self.songs.count >= index) {
        [array insertObject:song atIndex:++index]; //当前播放下标后面
        self.songs = array;
    }
}
-(void)insertSongAtEndItem:(Song *)song{
    MPMusicPlayerPlayParameters *parameter = [[MPMusicPlayerPlayParameters alloc] initWithDictionary:song.playParams];
    MPMusicPlayerPlayParametersQueueDescriptor *queue = [[MPMusicPlayerPlayParametersQueueDescriptor alloc] initWithPlayParametersQueue:@[parameter,]];
    [MainPlayer appendQueueDescriptor:queue];

    //插入添加数据
    if (self.songs.count > 0) {
        self.songs = [self.songs arrayByAddingObject:song];
    }
}
-(void)playMusicVideos:(NSArray<MusicVideo *> *)mvs startIndex:(NSUInteger)startIndex{
    NSMutableArray<MPMusicPlayerPlayParameters*> *array = [NSMutableArray array];
    for (MusicVideo *mv in mvs) {
        [array addObject:[[MPMusicPlayerPlayParameters alloc] initWithDictionary:mv.playParams]];
    }
    MPMusicPlayerPlayParametersQueueDescriptor *queue = [[MPMusicPlayerPlayParametersQueueDescriptor alloc] initWithPlayParametersQueue:array];
    [queue setStartItemPlayParameters:[array objectAtIndex:startIndex]];
    [self openToPlayQueueDescriptor:queue];
}

#pragma mark - Helper
/**获取歌曲rating 状态, 并设置 红心开关状态*/
-(void)heartFromSongIdentifier:(NSString*) identifier{
    if (identifier) {
        [MusicKit.new.api.library getRating:@[identifier,] byType:CRatingSongs callBack:^(NSDictionary *json, NSHTTPURLResponse *response) {
            BOOL like = (json && response.statusCode==200) ? YES : NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.playerView.heartIcon setEnabled:YES];
                [self.playerView.heartIcon setOn:like];
            });
        }];
    }
}

#pragma mark - getter



-(PlayerView *)playerView{
    if (!_playerView) {
        _playerView = [[PlayerView alloc] initWithFrame:self.view.bounds];

        //事件绑定
        [_playerView.heartIcon addTarget:self action:@selector(changeLove:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playerView;
}



#pragma mark - setter
-(void)setSongs:(NSArray<Song *> *)songs{
    if (_songs != songs) {
        _songs = songs;

        NSMutableArray<MPMusicPlayerPlayParameters*> *array = [NSMutableArray array];
        for (Song *song  in songs) {
            MPMusicPlayerPlayParameters *paramter = [[MPMusicPlayerPlayParameters alloc] initWithDictionary:song.playParams];
            if (paramter != nil) {
                 [array addObject:paramter];
            }
        }
        self.parametersQueue = [[MPMusicPlayerPlayParametersQueueDescriptor alloc] initWithPlayParametersQueue:array];
    }
}

#pragma mark - Button Action
/**下滑手势*/
-(void) closeViewController{
    NSLog(@"dis");
    [self dismissViewControllerAnimated:YES completion:nil];

}



-(void) animationButton:(UIButton*) sender{
    [UIView animateWithDuration:0.2 animations:^{
        [sender setTransform:CGAffineTransformMakeScale(0.88, 0.88)];
    } completion:^(BOOL finished) {
        if (finished) {
            //恢复
            [UIView animateWithDuration:0.2 animations:^{
                [sender setTransform:CGAffineTransformIdentity];
            }];
        }
    }];
}

//红心按钮 添加喜欢或者删除喜欢
- (void)changeLove:(MySwitch*) heart{

    NSString *identifier = MainPlayer.nowPlayingItem.playbackStoreID;
    // 查询当前rating状态(不是基于当前按钮状态)  --> 操作
    [MusicKit.new.api.library getRating:@[identifier,] byType:CRatingSongs callBack:^(NSDictionary *json, NSHTTPURLResponse *response) {
        (json && response.statusCode==200) ? [self deleteRatingForSongId:identifier] : [self addRatingForSongId:identifier];
//
//        if (json && response.statusCode==200) {
//            //当前为喜欢状态 /取消喜欢
//            [self deleteRatingForSongId:identifier];
//        }else{
//            //当前没有添加为喜欢/添加喜欢
//            [self addRatingForSongId:identifier];
//        }
    }];
}

-(void) deleteRatingForSongId:(NSString*)identifier{
    [MusicKit.new.api.library deleteRating:identifier byType:CRatingSongs callBack:^(NSDictionary *json, NSHTTPURLResponse *response) {
        if (response.statusCode/10 == 20) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.playerView.heartIcon setOn:NO];
            });
        }
    }];
}

/**添加到播放列表中,
 0.添加rating, 成功后,执行添加到库播放列表中
 1.先查询播放列表id
 2.添加到播放列表中,
 3.存储到数据库中
 */
-(void) addRatingForSongId:(NSString*)song{
    //添加rating
    [MusicKit.new.api.library addRating:song byType:CRatingSongs value:1 callBack:^(NSDictionary *json, NSHTTPURLResponse *response) {
        if (response.statusCode/10==20) {
            //请求Rating 的默认库播放列表 identifier,
            [MusicKit.new.api.library searchForTerm:@"Rating" byType:SLibraryPlaylists callBack:^(NSDictionary *json, NSHTTPURLResponse *response) {
                NSDictionary *track = @{@"id":song,@"type":@"songs"};
                NSArray *list = [json valueForKeyPath:@"results.library-playlists.data"];
                NSString *identifier = [list.firstObject valueForKey:@"id"];

                [MusicKit.new.api.library addTracksToLibraryPlaylists:identifier tracks:@[track,] callBack:^(NSDictionary *json, NSHTTPURLResponse *response) {

                }];
            }];
            //更新ui
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.playerView.heartIcon setOn:YES];
            });
        }
    }];
}
-(void)addResourceToLibrary:(NSString*) identifier{
    [MusicKit.new.api.library addResourceToLibraryForIdentifiers:@[identifier,] byType:AddSongs callBack:^(NSDictionary *json, NSHTTPURLResponse *response) {

        //更新ui
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.playerView.heartIcon setOn:YES];
        });
    }];
}

@end
