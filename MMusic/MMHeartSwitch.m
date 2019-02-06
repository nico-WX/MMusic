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

#import "DataManager.h"

@interface MMHeartSwitch()
@property(nonatomic, strong) UIImpactFeedbackGenerator *impact;

@property(nonatomic,strong) id observer;
@end

@implementation MMHeartSwitch

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {

        _impact = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
        [self setBackgroundColor:[UIColor colorWithWhite:1 alpha:0]];

        //处理事件
        __weak typeof(self) weakSelf = self;
        [self handleControlEvent:UIControlEventTouchUpInside withBlock:^{
            [weakSelf.impact impactOccurred];
            BOOL now = weakSelf.isOn;
            [weakSelf setOn:!now];
        }];

        //初始状态
        [self enableStateWithIdentifier:MainPlayer.nowPlayingItem.playbackStoreID];
        [MainPlayer nowPlayingSong:^(Song * _Nullable song) {
            [self updateWithSong:song];
        }];

        // 播放item 改变, 更新状态
        _observer = [[NSNotificationCenter defaultCenter] addObserverForName:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            [MainPlayer nowPlayingSong:^(Song * _Nullable song) {
                [self updateWithSong:song];
            }];
            [self enableStateWithIdentifier:MainPlayer.nowPlayingItem.playbackStoreID];
        }];
    }
    return self;
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:_observer];
    _observer = nil;
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
                if (on) {
                    [DataStore.new addRatingToCatalogWith:song.identifier type:RTCatalogSongs callBack:^(BOOL succeed) {
                        //网络上添加不成功, 设置no
                        if (!succeed){
                            self->_on = NO;
                        }
                    }];
                    [[DataManager shareDataManager] addItem:song];
                }else{
                    [DataStore.new deleteRatingForCatalogWith:song.identifier type:RTCatalogSongs callBack:^(BOOL succeed) {
                        self->_on = !succeed; // 成功删除, 设置为NO
                    }];
                    [[DataManager shareDataManager] deleteItem:song];
                }
            }];
        });
    }
}

//网络更新
- (void)updateWithSong:(Song*)song{
    mainDispatch(^{
        if (!song) {
            [self setOn:NO];
            [self setEnabled:NO];
            return;
        }

        [self setEnabled:YES];
        [DataStore.new requestRatingForCatalogWith:song.identifier type:RTCatalogSongs callBack:^(BOOL isRating) {
            [self setOn:isRating];
        }];
    });

}


// 有identifier  可以启用按钮
-(void)enableStateWithIdentifier:(NSString*)identifier {
    BOOL enable = (identifier && ![identifier isEqualToString:@"0"]) ? YES : NO;
    [self setEnabled:enable];
}


//简单的缩小-->恢复原始状态 动画
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
