//
//  PlayControllerView.h
//  MMusic
//
//  Created by Magician on 2018/4/14.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>

/**播放器控制按钮*/
@interface PlayControllerView : UIView

/**上一首*/
@property(nonatomic, strong,readonly) UIButton *previous;
/**播放或暂停*/
@property(nonatomic, strong,readonly) UIButton *play;
/**下一首*/
@property(nonatomic, strong,readonly) UIButton *next;

@end
