//
//  AlbumsSongCell.h
//  MMusic
//
//  Created by Magician on 2018/5/29.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NAKPlaybackIndicatorView.h>

@interface AlbumsSongCell : UITableViewCell
/**歌曲编号*/
@property(nonatomic, strong) UILabel *numberLabel;
@property(nonatomic, strong) Song *song;
/**歌曲当前播放状态*/
@property(nonatomic, assign) NAKPlaybackIndicatorViewState state;
@end
