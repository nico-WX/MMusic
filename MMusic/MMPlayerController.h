//
//  MMPlayer.h
//  MMusic
//
//  Created by Magician on 2017/12/3.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface MMPlayerController : NSObject
/**播放参数 字典数组*/
@property(nonatomic, strong) NSArray<NSDictionary*> *parameters;
@property(nonatomic, strong) MPMusicPlayerController *player;

+(instancetype) sharePlayerController;
@end
