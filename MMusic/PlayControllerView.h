//
//  PlayControllerView.h
//  MMusic
//
//  Created by Magician on 2018/4/14.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>
@class VBFPopFlatButton;
/**播放器控制按钮*/
@interface PlayControllerView : UIView
//Player Controller
/**上一首*/
@property(nonatomic, strong) VBFPopFlatButton *previous;
/**播放或暂停*/
@property(nonatomic, strong) VBFPopFlatButton *play;
/**下一首*/
@property(nonatomic, strong) VBFPopFlatButton *next;

@end
