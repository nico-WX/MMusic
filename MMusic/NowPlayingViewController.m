//
//  RedViewController.m
//  ScrollPage
//
//  Created by 🐙怪兽 on 2018/11/8.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import <Masonry.h>

#import "NowPlayingViewController.h"
#import "MPMusicPlayerController+ResourcePlaying.h"
#import "PlayProgressView.h"
#import "MMHeartSwitch.h"

#import "MMDataStack.h"
#import "MMCDMO_Song.h"

#import "DataStoreKit.h"
#import "Artwork.h"
#import "Song.h"

@interface NowPlayingViewController ()

@property(nonatomic, strong)UIImageView *artworkView;           // 海报图片
@property(nonatomic, strong)PlayProgressView *playProgressView; // 播放进度控制

@property(nonatomic, strong)UILabel *songNameLabel,*artistLabel;    // 歌曲名称和艺人名称
@property(nonatomic, strong)UIButton *previousButton,*playButton,*nextButton;   // 播放控制按钮
@property(nonatomic, strong)MMHeartSwitch *heartSwitch;         // 心脏开关
@end

static NowPlayingViewController *_instance;
@implementation NowPlayingViewController

#pragma mark - init

+ (instancetype)sharePlayerViewController {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_instance){
            _instance = [super allocWithZone:zone];
        }
    });
    return _instance;
}

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

        //设置偏移,  x=y=0 时, 没约束前会出现在左上角, 视图第一次弹出(poping)时,才布局
        _heartSwitch.frame = CGRectMake(200, 200, 30, 30);
        _playProgressView.frame = CGRectMake(200, 200, 30, 30);

        [_artworkView setBackgroundColor:[UIColor colorWithWhite:0.95 alpha:1]];

        [self.view addSubview:_heartSwitch];
        [self.view addSubview:_artworkView];
        [self.view addSubview:_playProgressView];
        [self.view addSubview:_songNameLabel];
        [self.view addSubview:_artistLabel];
        [self.view addSubview:_previousButton];
        [self.view addSubview:_playButton];
        [self.view addSubview:_nextButton];

        // Llabel 文本 setter
        [_songNameLabel setAdjustsFontSizeToFitWidth:YES];
        [_songNameLabel setTextColor:MainColor];
        [_songNameLabel setFont:[UIFont systemFontOfSize:[UIFont buttonFontSize]]];

        [_artistLabel setTextColor:UIColor.grayColor];
        [_artistLabel setFont:[UIFont systemFontOfSize:[UIFont smallSystemFontSize]]];
        [_artistLabel setAdjustsFontSizeToFitWidth:YES];
    }
    return self;
}

# pragma mark - lift cycle

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self updateCurrentItemMetadata];
}

- (void)viewDidLoad{
    [super viewDidLoad];

    //绑定播放按钮事件
    [_heartSwitch addTarget:self action:@selector(changeLove:) forControlEvents:UIControlEventTouchUpInside];
    //上一首
    [_previousButton handleControlEvent:UIControlEventTouchUpInside withBlock:^{
        [self animationButton:self.previousButton];
        [MainPlayer skipToPreviousItem];
    }];
    // 播放或暂停
    [_playButton handleControlEvent:UIControlEventTouchUpInside withBlock:^{
        [self animationButton:self.playButton];
        switch (MainPlayer.playbackState) {
            case MPMusicPlaybackStatePaused:
            case MPMusicPlaybackStateStopped:
            case MPMusicPlaybackStateInterrupted:
                [MainPlayer play];
                break;
            case MPMusicPlaybackStatePlaying:
                [MainPlayer pause];

            default:
                break;
        }
    }];
    //下一首
    [_nextButton handleControlEvent:UIControlEventTouchUpInside withBlock:^{
        [self animationButton:self.nextButton];
        [MainPlayer skipToNextItem];
    }];

    [[NSNotificationCenter defaultCenter] addObserverForName:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self updateButtonImage];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self updateCurrentItemMetadata];
    }];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    

    if (CGRectGetHeight(self.view.frame) < 100) {
        [self popStateLayout];
    }else{
        [self poppingStateLayout];
        //打开时, 刷新图片大小,
    }
    // 更新按钮照片
    [self updateButtonImage];
}


#pragma mark - help method
// 窗口缩放在视图下部时
- (void)popStateLayout{
    //更改文本对齐
    [self.songNameLabel setTextAlignment:NSTextAlignmentLeft];
    [self.artistLabel setTextAlignment:NSTextAlignmentLeft];

    UIEdgeInsets padding = UIEdgeInsetsMake(4, 4, 4, 4);
    UIView *superView = self.view;
    __weak typeof(self) weakSelf = self;
    CGFloat itemW = CGRectGetHeight(superView.bounds) - (padding.top*2);

    [self.artworkView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.mas_equalTo(superView).insets(padding);
        make.width.mas_equalTo(itemW);
    }];

    [self.nextButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        [make setRemoveExisting:YES];
        make.top.right.bottom.mas_equalTo(superView).insets(padding);
        make.width.mas_equalTo(itemW);
    }];

    [self.playButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(superView).insets(padding);
        make.right.mas_equalTo(weakSelf.nextButton.mas_left).offset(padding.right);
        make.width.mas_equalTo(itemW);
    }];

    [self.songNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.artworkView.mas_right).offset(padding.left);
        make.right.mas_equalTo(weakSelf.playButton.mas_left).offset(-padding.right);
        make.bottom.mas_equalTo(superView).offset(-CGRectGetMidY(superView.bounds));
        make.top.mas_lessThanOrEqualTo(superView).offset(padding.top);
    }];

    [self.artistLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.songNameLabel.mas_bottom);
        make.left.right.mas_equalTo(weakSelf.songNameLabel);
        make.bottom.mas_lessThanOrEqualTo(superView).inset(padding.bottom);
    }];
}

// 视图全部打开状态
- (void)poppingStateLayout{
    //更改文本对齐
    [self.songNameLabel setTextAlignment:NSTextAlignmentCenter];
    [self.artistLabel setTextAlignment:NSTextAlignmentCenter];

    //边距
    UIEdgeInsets padding = UIEdgeInsetsMake(40, 20, 20, 20);
    UIView *superView = self.view;
    __weak typeof(self) weakSelf = self;

    // artworkView布局 与pop状态下的按钮布局 发生冲突(覆盖), 后面更新约束即可更正;
    //移除 , 消除约束警告
    ({
        [self.playButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            [make setRemoveExisting:YES];
        }];
        [self.nextButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            [make setRemoveExisting:YES];
        }];
    });

    //重新布局
    [self.artworkView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(superView).insets(padding);
        CGFloat h = CGRectGetWidth(superView.frame) - (padding.left+padding.right);
        make.height.mas_equalTo(h);
    }];

    [self.playProgressView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.artworkView.mas_bottom).offset(padding.top/3);
        make.left.right.mas_equalTo(superView).insets(padding);
        make.height.mas_equalTo(40);
    }];

    [self.songNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.playProgressView.mas_bottom).offset(padding.top/3);
        make.left.right.mas_equalTo(superView).insets(padding);
    }];
    [self.artistLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.songNameLabel.mas_bottom).offset(10);
        make.left.right.mas_equalTo(superView).insets(padding);
    }];

    // size
    CGFloat h = 44.0f;
    CGFloat w = h;
    CGSize buttonSize = CGSizeMake(w, h);  //w

    // point
    // 基于父视图偏移, 建立约束时, 减去左边偏移的一半
    CGFloat x1 = CGRectGetMidX(self.artistLabel.frame)/2 + padding.left/2;
    CGFloat x2 = x1*2;
    CGFloat x3 = x1*3;

    [self.previousButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.artistLabel.mas_bottom).offset(padding.top/2);
        make.left.mas_equalTo(superView).offset(x1 - h/2);
        make.size.mas_equalTo(buttonSize);
    }];

    [self.playButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.previousButton.mas_top);
        make.left.mas_equalTo(superView).offset(x2 - h/2);
        make.size.mas_equalTo(buttonSize);
    }];

    [self.nextButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.playButton.mas_top);
        make.left.mas_equalTo(superView).offset(x3 - h/2);
        make.size.mas_equalTo(buttonSize);
    }];

    CGFloat heartW = 30.0f;
    [self.heartSwitch mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(weakSelf.playButton.mas_centerX);
        make.top.mas_equalTo(weakSelf.playButton.mas_bottom).offset(padding.top/2);
        make.size.mas_equalTo(CGSizeMake(heartW, heartW));
    }];


    //处理照片分辨率
    [self setupArtworkImage];
}


#pragma mark - button animation
- (void)animationButton:(UIButton*)sender{
    [UIView animateWithDuration:0.2 animations:^{
        [sender setTransform:CGAffineTransformMakeScale(0.88, 0.88)];
    } completion:^(BOOL finished) {
        //恢复
        [UIView animateWithDuration:0.2 animations:^{
            [sender setTransform:CGAffineTransformIdentity];
        }];
    }];
}

- (void)updateButtonImage{
    CGFloat h = CGRectGetHeight(self.view.frame);
    //pop state
    if (h<100) {
        // title FontSize
        //[self.songNameLabel setFont:[UIFont systemFontOfSize:20]];
        [self.nextButton setImage:[UIImage imageNamed:@"nextFwd"] forState:UIControlStateNormal];
        switch (MainPlayer.playbackState) {
            case MPMusicPlaybackStateStopped:
            case MPMusicPlaybackStatePaused:
            case MPMusicPlaybackStateInterrupted:
                [self.playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
                break;

            case MPMusicPlaybackStatePlaying:
                [self.playButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
                break;

            default:
                break;
        }

    }else{
        //open state (popping)
        // title FontSize
        //[self.songNameLabel setFont:[UIFont systemFontOfSize:26]];
        [self.previousButton setImage:[UIImage imageNamed:@"nowPlaying_prev"] forState:UIControlStateNormal];
        [self.nextButton setImage:[UIImage imageNamed:@"nowPlaying_next"] forState:UIControlStateNormal];
        switch (MainPlayer.playbackState) {
            case MPMusicPlaybackStatePaused:
            case MPMusicPlaybackStateStopped:
            case MPMusicPlaybackStateInterrupted:
                [self.playButton setImage:[UIImage imageNamed:@"nowPlaying_play"] forState:UIControlStateNormal];
                break;
            case MPMusicPlaybackStatePlaying:
                [self.playButton setImage:[UIImage imageNamed:@"nowPlaying_pause"] forState:UIControlStateNormal];
                break;
            default:
                break;
        }
    }
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


    //播放的时候, 有可能在播放第三方音乐, 从而控制喜欢开关是否有效(但4G网络播放未开启时,可能也没有playbackStoreID)
    self.heartSwitch.enabled = identifier ? YES  : NO;
    //红心状态
    [self heartFromSongIdentifier:identifier];

    [self.songNameLabel setText:nowPlayingItem.title];
    [self.artistLabel setText:nowPlayingItem.artist];
    [self setupArtworkImage];
}

- (void)setupArtworkImage{

    MPMediaItem *nowPlayingItem = MainPlayer.nowPlayingItem;
    NSString *identifier = MainPlayer.nowPlayingItem.playbackStoreID;
    UIImage *image  = [nowPlayingItem.artwork imageWithSize:CGSizeMake(200, 200)];
    if (image) {
        [self.artworkView setImage:image];
        return;
    }
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


/**获取歌曲rating 状态, 并设置 红心开关状态*/
-(void)heartFromSongIdentifier:(NSString*)identifier {
    if (!identifier) return;
    [DataStore.new requestRatingForCatalogWith:identifier type:RTCatalogSongs callBack:^(BOOL isRating) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.heartSwitch setOn:isRating];
            [self.heartSwitch setEnabled:YES];

            if (isRating) {
                //手动触发,已有数据添加到数据库
                [self changeLove:self.heartSwitch];
            }
        });
    }];
}
//红心按钮 添加喜欢或者删除喜欢
- (void)changeLove:(MMHeartSwitch*)heart {
    [MainPlayer nowPlayingSong:^(Song * _Nonnull song) {
        [self updateState:heart withSong:song];
    }];
}

- (void)updateState:(MMHeartSwitch*)heartswitch withSong:(Song*)song{
    dispatch_async(dispatch_get_main_queue(), ^{
        //更新远程及本地数据库
        NSString *identifier = MainPlayer.nowPlayingItem.playbackStoreID;
        if ([heartswitch isOn]) {
            [DataStore.new addRatingToCatalogWith:identifier type:RTCatalogSongs callBack:^(BOOL succeed) {
                [heartswitch setOn:succeed];
            }];
            [self addSongToCoreData:song];

        }else{
            [DataStore.new deleteRatingForCatalogWith:identifier type:RTCatalogSongs callBack:^(BOOL succeed) {
                [heartswitch setOn:!succeed];
            }];
            [self deleteSong:song];
        }
    });
}

- (void)addSongToCoreData:(Song*)song{
    NSManagedObjectContext *moc = [MMDataStack shareDataStack].context;
    MMCDMO_Song *addSong = [[MMCDMO_Song alloc] initWithSong:song];
    NSLog(@"add song =%@",addSong);

    //addSong.playParams[@"key"];


    NSError *validateError = nil;
    NSString *checkID = addSong.playParams[@"id"];
    BOOL validate = [addSong validateValue:&checkID forKeyPath:@"playParams.id" error:&validateError];
    if (validate) {
        NSLog(@"validate !");
        return;
    }
    NSLog(@"not validate!");

    NSError *saveError = nil;
    //[moc save:&saveError];
    if (![moc save:&saveError]) {
        NSLog(@"保存失败 error =%@",saveError);
    }

    //NSAssert(saveError, @"保存Song到本地数据库失败");
}
- (void)deleteSong:(Song*)song{
    NSManagedObjectContext *moc = [MMDataStack shareDataStack].context;
    NSPredicate *namePre = [NSPredicate predicateWithFormat:@"%K == %@",@"name",song.name];
    NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:@"Song"]; //MMCDMO_Song 类映射到模型文件中的 Song实体
    [fetch setPredicate:namePre];
    [fetch setFetchLimit:5];
    [fetch setReturnsObjectsAsFaults:NO]; //返回填充实例,不使用惰值

    NSError *fetchError = nil;
    NSArray *fetchObjects = [moc executeFetchRequest:fetch error:&fetchError];
    NSLog(@"fetch Obj = %@",fetchObjects);

    //NSAssert(fetchError, @"获取失败");
    if (fetchObjects) {
        return;
    }
    //匹配播放参数ID, 删除
    for (MMCDMO_Song *sqlSong in fetchObjects) {
        NSString *lID = song.playParams[@"id"];
        NSString *sqlID = sqlSong.playParams[@"id"];
        if ([lID isEqualToString:sqlID]) {
            [moc deleteObject:sqlSong];
            NSLog(@"删除成功");
        }
    }

}


@end
