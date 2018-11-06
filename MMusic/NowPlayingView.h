//
//  NowPlayingView.h
//  MMusic
//
//  Created by Magician on 2018/3/11.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MySwitch.h"

/**播放器视图*/
@interface NowPlayingView : UIView
/**专辑封面*/
@property(nonatomic, strong,readonly) UIImageView *artworkView;
/**歌曲名称*/
@property(nonatomic, strong,readonly)UILabel *songNameLabel;
/**艺人名 或者 专辑信息*/
@property(nonatomic, strong,readonly)UILabel *artistLabel;

/**喜爱按钮*/
@property(nonatomic, strong,readonly)MySwitch *heartIcon;
/**循环模式*/
@property(nonatomic, strong,readonly)UIButton *repeat;
@end
