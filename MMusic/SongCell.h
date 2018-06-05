//
//  SongCell.h
//  MMusic
//
//  Created by Magician on 2018/3/11.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NAKPlaybackIndicatorView.h>
@class Song;

@interface SongCell : UITableViewCell
/**歌曲编号*/
@property(nonatomic, strong,readonly) UILabel *numberLabel;
@property(nonatomic, strong) Song *song;
/**歌曲当前播放状态*/
@property(nonatomic, assign) NAKPlaybackIndicatorViewState state;

@end
