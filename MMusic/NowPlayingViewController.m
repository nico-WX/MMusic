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
#import "DataStoreKit.h"

#import "PlayProgressView.h"
#import "MMHeartSwitch.h"

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
        _heartSwitch        = [MMHeartSwitch new];

        _heartSwitch.frame = CGRectMake(200, 200, 30, 30);      //设置偏移,  x=y=0 时, 没约束前会出现在左上角
        _playProgressView.frame = CGRectMake(200, 200, 30, 30);

        [self.view addSubview:_heartSwitch];
        [self.view addSubview:_artworkView];
        [self.view addSubview:_playProgressView];
        [self.view addSubview:_songNameLabel];
        [self.view addSubview:_artistLabel];
        [self.view addSubview:_previousButton];
        [self.view addSubview:_playButton];
        [self.view addSubview:_nextButton];

        //绑定播放按钮事件
        [self addButtonActivation];
        [_heartSwitch addTarget:self action:@selector(changeLove:) forControlEvents:UIControlEventTouchUpInside];

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
    NSString *identifier = MainPlayer.nowPlayingItem.playbackStoreID;

    if (!nowPlayingItem) {
        [self.heartSwitch setEnabled:NO];
        //self.artworkView setImage:
        [self.songNameLabel setText:@"当前无歌曲播放"];
        [self.artistLabel setText:@"----"];
        return;
    }

    ({
        //播放的时候, 有可能在播放第三方音乐, 从而控制喜欢开关是否有效(但4G网络播放未开启时,可能也没有playbackStoreID)
        self.heartSwitch.enabled = identifier ? YES  : NO;

        //红心状态
        [self heartFromSongIdentifier:identifier];

        [self.songNameLabel setText:nowPlayingItem.title];
        [self.artistLabel setText:nowPlayingItem.artist];

        UIImage *image  = [nowPlayingItem.artwork imageWithSize:self.artworkView.bounds.size];
        if (image) {
            [self.artworkView setImage:image];
            return;
        }
    });

    //本地无数据, 从网络 请求
    if (identifier) {
        [MusicKit.new.catalog resources:@[identifier,] byType:CatalogSongs callBack:^(NSDictionary *json, NSHTTPURLResponse *response) {
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
-(void)heartFromSongIdentifier:(NSString*)identifier {
    if (!identifier) return;
    [DataStore.new requestRatingForCatalogWith:identifier type:RTCatalogSongs callBack:^(BOOL isRating) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.heartSwitch setOn:isRating];
            [self.heartSwitch setEnabled:YES];
        });
    }];
}
//红心按钮 添加喜欢或者删除喜欢
- (void)changeLove:(MMHeartSwitch*)heart {

    //从 on --> off 时 表示要删除
    //从 off --> on 时 表示要添加rating 到catalog
    // 播放器的 识别 llibrary 音乐  或者catalog 音乐

    NSString *identifier = MainPlayer.nowPlayingItem.playbackStoreID;
    if ([heart isOn]) {
        [DataStore.new addRatingToCatalogWith:identifier type:RTCatalogSongs callBack:^(BOOL succeed) {
            [heart setOn:succeed];
        }];
    }else{
        [DataStore.new deleteRatingForCatalogWith:identifier type:RTCatalogSongs callBack:^(BOOL succeed) {
            [heart setOn:!succeed];
        }];
    }
}


@end
