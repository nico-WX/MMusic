//
//  RedViewController.m
//  ScrollPage
//
//  Created by 🐙怪兽 on 2018/11/8.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import "NowPlayingViewController.h"
#import "NowPlayingViewController+Layout.h"
#import "NowPlayingViewController+UpdateUIState.h"
#import "MPMusicPlayerController+ResourcePlaying.h"

#import "PlayProgressView.h"
#import "MySwitch.h"

#import "Artwork.h"
#import "Song.h"


#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <Masonry.h>


@interface NowPlayingViewController ()

@end

static NowPlayingViewController *_instance;
@implementation NowPlayingViewController

- (instancetype)init{
    if (self = [super init]) {
        _artworkView        = [UIImageView new];
        _playProgressView   = [PlayProgressView new];
        _songNameLabel      = [UILabel new];
        _artistLabel        = [UILabel new];
        _previousButton     = [UIButton new];
        _playButton         = [UIButton new];
        _nextButton         = [UIButton new];
        _heartSwitch        = [MySwitch new];

        [self.view addSubview:_heartSwitch];
        [self.view addSubview:_artworkView];
        [self.view addSubview:_playProgressView];
        [self.view addSubview:_songNameLabel];
        [self.view addSubview:_artistLabel];
        [self.view addSubview:_previousButton];
        [self.view addSubview:_playButton];
        [self.view addSubview:_nextButton];

        
        [_songNameLabel setFont:[UIFont systemFontOfSize:24]];
        [_songNameLabel setAdjustsFontSizeToFitWidth:YES];
        [_artistLabel setTextColor:UIColor.grayColor];

        [[NSNotificationCenter defaultCenter] addObserverForName:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            [self updateButton];
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            [self updateCurrentItemMetadata];
        }];
    }
    return self;
}

+ (instancetype)sharePlayerViewController {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    //防止同时访问
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_instance){
            _instance = [super allocWithZone:zone];
        }
    });
    return _instance;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    [self updateCurrentItemMetadata];
}


-(void)updateCurrentItemMetadata{
    MPMediaItem *nowPlayingItem = MainPlayer.nowPlayingItem;

    if (!MainPlayer.nowPlayingItem) {
        [self.heartSwitch setEnabled:NO];
        self.artworkView.image = nil;
        self.songNameLabel.text = @"当前无歌曲播放";
        self.artistLabel.text = @"-- --";
        return;
    }

    ({
        //播放的时候, 有可能在播放第三方音乐, 从而控制喜欢开关是否有效(但4G网络播放未开启时,可能也没有playbackStoreID)
        self.heartSwitch.enabled = nowPlayingItem.playbackStoreID ? YES  : NO;
        //红心状态
        [self heartFromSongIdentifier:nowPlayingItem.playbackStoreID];

        [self.songNameLabel setText:nowPlayingItem.title];
        [self.artistLabel setText:nowPlayingItem.artist];

        UIImage *image  = [nowPlayingItem.artwork imageWithSize:self.artworkView.bounds.size];
        if (image) {
            [self.artworkView setImage:image];
            //提前return
            return;
        }
    });

    //清除旧数据
    if (nowPlayingItem.playbackStoreID) {
        [MusicKit.new.api resources:@[nowPlayingItem.playbackStoreID]
                             byType:CatalogSongs
                           callBack:^(NSDictionary *json, NSHTTPURLResponse *response) {

                               json = [[[json valueForKey:@"data"] firstObject] valueForKey:@"attributes"];
                               Song *song = [Song instanceWithDict:json];
                               [self showImageToView:self.artworkView withImageURL:song.artwork.url cacheToMemory:YES];
                           }];
    }else{
        for (Song *song in MainPlayer.songLists ) {
            if ([song isEqualToMediaItem:nowPlayingItem]) {
                [self showImageToView:self.artworkView withImageURL:song.artwork.url cacheToMemory:YES];
            }
        }
    }

}

#pragma mark - Helper
/**获取歌曲rating 状态, 并设置 红心开关状态*/
-(void)heartFromSongIdentifier:(NSString*) identifier{
    if (identifier) {
        [MusicKit.new.api.library getRating:@[identifier,] byType:CRatingSongs callBack:^(NSDictionary *json, NSHTTPURLResponse *response) {
            BOOL like = (json && response.statusCode==200) ? YES : NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.heartSwitch setEnabled:YES];
                [self.heartSwitch setOn:like];
            });
        }];
    }
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
                [self.heartSwitch setOn:NO];
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
                [self.heartSwitch setOn:YES];
            });
        }
    }];
}

-(void)addResourceToLibrary:(NSString*) identifier{
    [MusicKit.new.api.library addResourceToLibraryForIdentifiers:@[identifier,]
                                                          byType:AddSongs
                                                        callBack:^(NSDictionary *json, NSHTTPURLResponse *response) {

                                                            //更新ui
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                [self.heartSwitch setOn:YES];
                                                            });
                                                        }];
}





//- (void)popupViewDidOpenWithBounds:(CGRect)bounds{
//    NSLog(@">>>>>>>>>> open");
//    //[self openStateLayout];
//}
//
//- (void)popupViewDidCloseWithBounds:(CGRect)bounds{
//    NSLog(@">>>>> close");
//   // [self popupStateLayout];
//}


@end
