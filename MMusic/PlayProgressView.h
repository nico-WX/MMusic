//
//  PlayProgressView.h
//  MMusic
//
//  Created by Magician on 2018/4/14.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayProgressView : UIView
/**已经播放的时间*/
@property(nonatomic, strong) UILabel *currentTime;
/**歌曲时长*/
@property(nonatomic, strong) UILabel *durationTime;
/**播放进度条*/
@property(nonatomic, strong) UISlider *progressSlider;
@end
