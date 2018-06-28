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
/**当前song*/
@property(nonatomic, strong) Song *song;
@end
