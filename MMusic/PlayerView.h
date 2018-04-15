//
//  PlayerView.h
//  MMusic
//
//  Created by Magician on 2018/3/11.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PlayProgressView;
@class PlayControllerView;

/**播放器视图*/
@interface PlayerView : UIView

/**关闭视图按钮*/
@property(nonatomic, strong) UIButton *closeButton;
/**专辑封面*/
@property(nonatomic, strong) UIImageView *artworkView;
/**播放进度视图*/
@property(nonatomic, strong) PlayProgressView *progressView;
/**歌曲名称*/
@property(nonatomic, strong) UILabel *songNameLabel;
/**艺人名 或者 专辑信息*/
@property(nonatomic, strong) UILabel *artistLabel;

@property(nonatomic ,strong) PlayControllerView *playCtrView;

/**喜爱按钮*/
@property(nonatomic, strong) UIButton *like;
/**循环模式*/
@property(nonatomic, strong) UIButton *repeat;
@end
