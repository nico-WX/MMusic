//
//  MMHeartSwitch.m
//  CustomSwitch
//
//  Created by Magician on 2018/7/4.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import "MMHeartSwitch.h"
#import "ButtonStyleKit.h"
#import "MPMusicPlayerController+ResourcePlaying.h"
#import "DataStoreKit.h"
#import "CoreDataStack.h"
#import "SongManageObject.h"

@interface MMHeartSwitch()
@property(nonatomic, strong) UIImpactFeedbackGenerator *impact;
@end

@implementation MMHeartSwitch

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {

        _impact = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
        [self setBackgroundColor:[UIColor colorWithWhite:1 alpha:0]];

        //内部直接绑定事件, 处理请求, 分散代码
        __weak typeof(self) weakSelf = self;
        [self handleControlEvent:UIControlEventTouchUpInside withBlock:^{
            [weakSelf.impact impactOccurred];
            weakSelf.on = !weakSelf.isOn;
        }];


        [self stateWithSongIdentifier:MainPlayer.nowPlayingItem.playbackStoreID];

        [[NSNotificationCenter defaultCenter] addObserverForName:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            NSLog(@"chage --->");
            NSLog(@"id === %@",MainPlayer.nowPlayingItem.playbackStoreID);
            [self stateWithSongIdentifier:MainPlayer.nowPlayingItem.playbackStoreID];
        }];

        [[NSNotificationCenter defaultCenter] addObserverForName:MPMusicPlayerControllerQueueDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            NSLog(@"queue =%@",note.object);
        }];

    }
    return self;
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)drawRect:(CGRect)rect{
    if(self.on){
        [ButtonStyleKit drawOnCanvasWithFrame:rect resizing:ButtonStyleKitResizingBehaviorAspectFit];
    }else{
        [ButtonStyleKit drawOffCanvasWithFrame:rect resizing:ButtonStyleKitResizingBehaviorAspectFit];
    }
}

- (void)setOn:(BOOL)on{
    if (_on != on) {
        _on = on;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setNeedsDisplay];
            [self animationButton:self];

            [MainPlayer nowPlayingSong:^(Song * _Nullable song) {
                //可能返回空值
                if (song) {
                    [self updateState:self withSong:song];
                }else{
                    self->_on = NO;
                }
            }];
        });
    }
}

- (void)updateState:(MMHeartSwitch*)heartswitch withSong:(Song*)song{
    dispatch_async(dispatch_get_main_queue(), ^{
        //更新远程及本地数据库
        NSString *identifier = MainPlayer.nowPlayingItem.playbackStoreID;
        if ([identifier isEqualToString:@"0"]) {
            return ;
        }

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

    NSManagedObjectContext *moc = [CoreDataStack shareDataStack].context;

    //查询, 如果已经添加, 跳过
    NSString *identifier = [song.attributes.playParams valueForKey:@"id"];
    NSPredicate *idPredicate = [NSPredicate predicateWithFormat:@"%K == %@",@"identifier",identifier];
    NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:@"Song"];
    [fetch setPredicate:idPredicate];
    //[fetch setReturnsObjectsAsFaults:NO];
    NSError *error = nil;

    NSArray *results = [moc executeFetchRequest:fetch error:&error];
    if (results.count > 0) {
        NSLog(@"已经添加");
        return;
    }

    SongManageObject *addSong = [[SongManageObject alloc] initWithSong:song];

    NSAssert(addSong, @"生成托管对象失败");
    NSError *saveError = nil;
    if (![moc save:&saveError]) {
        NSLog(@"保存失败 error =%@",saveError);
    }else{
        NSLog(@"保存成功");
    }
}
- (void)deleteSong:(Song*)song{
    NSManagedObjectContext *moc = [CoreDataStack shareDataStack].context;
    NSPredicate *namePre = [NSPredicate predicateWithFormat:@"%K == %@",@"name",song.attributes.name];
    NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:@"Song"]; //MMCDMO_Song 类映射到模型文件中的 Song实体
    [fetch setPredicate:namePre];
    [fetch setFetchLimit:5];
    [fetch setReturnsObjectsAsFaults:NO]; //返回填充实例,不使用惰值

    NSError *fetchError = nil;
    NSArray *fetchObjects = [moc executeFetchRequest:fetch error:&fetchError];

    //NSAssert(fetchError, @"获取失败");
//    if (!fetchObjects) {
//        return;
//    }
    //匹配播放参数ID, 删除
    for (SongManageObject *sqlSong in fetchObjects) {
        NSString *lID = song.attributes.playParams[@"id"];
        NSString *sqlID = sqlSong.playParams[@"id"];
        if ([lID isEqualToString:sqlID]) {
            [moc deleteObject:sqlSong];
            NSLog(@"删除成功");
        }
    }
}
/**获取歌曲rating 状态, 并设置 红心开关状态*/
-(void)stateWithSongIdentifier:(NSString*)identifier {
    if (!identifier){
        [self setOn:NO];
        return;
    }
    [DataStore.new requestRatingForCatalogWith:identifier type:RTCatalogSongs callBack:^(BOOL isRating){
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"rating =%d",isRating);
            [self setOn:isRating];
            [self setEnabled:YES];

        });
    }];
}


//简单的缩小-->恢复原始状态
- (void)animationButton:(MMHeartSwitch*)sender {

    [UIView animateWithDuration:0.2 animations:^{
        [sender setTransform:CGAffineTransformMakeScale(0.8, 0.8)];
    } completion:^(BOOL finished) {
        if (finished){
            [UIView animateWithDuration:0.2 animations:^{
                [sender setTransform:CGAffineTransformIdentity];
            }];
        }
    }];
}

@end
