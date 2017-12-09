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
+(instancetype)sharePlayerController{
    return [[self alloc] init];
}

-(MPMusicPlayerController *)player{
    if (!_player) {
        _player = [MPMusicPlayerController systemMusicPlayer];
    }
    NSMutableArray *temp = [NSMutableArray array];
    for (NSDictionary *dict in _parameters ) {
        MPMusicPlayerPlayParameters *parameter = [[MPMusicPlayerPlayParameters alloc] initWithDictionary:dict];
        [temp addObject:parameter];
    }
    MPMusicPlayerPlayParametersQueueDescriptor *des = [[MPMusicPlayerPlayParametersQueueDescriptor alloc] initWithPlayParametersQueue:temp];
    [_player setQueueWithDescriptor:des];
    return _player;
}

-(void)setParameters:(NSArray<NSDictionary *> *)parameters{
    if (_parameters != parameters) {
        _parameters = parameters;
    }

}
@end
