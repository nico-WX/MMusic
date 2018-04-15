//
//  MMPlayer.m
//  MMusic
//
//  Created by Magician on 2017/12/3.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "MMPlayerController.h"
#import <MediaPlayer/MediaPlayer.h>


static MMPlayerController *_instance;

@implementation MMPlayerController
+ (instancetype)sharePlayerController{
    return [[self alloc] init];
}

- (MPMusicPlayerController*)player{
    if (!_player) {
        _player = [MPMusicPlayerController systemMusicPlayer];
    }
    [_player setRepeatMode:MPMusicRepeatModeAll];
    return _player;
}

- (void)setParameters:(NSArray<NSDictionary *> *)parameters{
    if (_parameters != parameters) {
        _parameters = parameters;
    }

}
@end
