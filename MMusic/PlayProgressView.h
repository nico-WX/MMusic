//
//  PlayProgressView.h
//  MMusic
//
//  Created by Magician on 2018/4/14.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>

//拆分代码  
@interface PlayProgressView : UIView
/**已经播放的时间*/
@property(nonatomic, strong, readonly) UILabel *currentTime;
/**歌曲时长*/
@property(nonatomic, strong, readonly) UILabel *durationTime;
/**播放进度条*/
@property(nonatomic, strong, readonly) UISlider *progressSlider;
@end

