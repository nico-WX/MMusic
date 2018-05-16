//
//  PlayerView.h
//  MMusic
//
//  Created by Magician on 2018/3/11.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VBFPopFlatButton.h>
#import <Lottie/Lottie.h>

/**播放器视图*/
@interface PlayerView : UIView
/**专辑封面*/
@property(nonatomic, strong,readonly) UIImageView *artworkView;
/**播放进度信息*/
@property(nonatomic,strong,readonly)UILabel *currentTime;
@property(nonatomic,strong,readonly)UILabel *durationTime;
@property(nonatomic,strong,readonly)UISlider *progressView;
/**歌曲名称*/
@property(nonatomic, strong,readonly) UILabel *songNameLabel;
/**艺人名 或者 专辑信息*/
@property(nonatomic, strong,readonly) UILabel *artistLabel;
/**上一首*/
@property(nonatomic, strong,readonly) VBFPopFlatButton *previous;
/**播放或暂停*/
@property(nonatomic, strong,readonly) VBFPopFlatButton *play;
/**下一首*/
@property(nonatomic, strong,readonly) VBFPopFlatButton *next;
/**喜爱按钮*/
@property(nonatomic, strong,readonly) LOTAnimatedSwitch *heartIcon;
/**循环模式*/
@property(nonatomic, strong,readonly) UIButton *repeat;
@end
