//
//  NowPlayingViewController.h
//  MMusic
//
//  Created by Magician on 2018/3/11.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>


//播放控制 及 info 更新  子控件事件拆分在各自的视图中, 信息统一通过MainPlayer 获取
@interface NowPlayingViewController : UIViewController
@property(nonatomic, readonly) UIImage *artworkImage;
/**播放器UI*/
//@property(nonatomic, strong) NowPlayingView *playerView;

/**单例*/
+ (instancetype)sharePlayerViewController;
@end
