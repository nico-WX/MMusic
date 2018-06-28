//
//  ChartsViewController.h
//  MMusic
//
//  Created by Magician on 2018/4/24.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MusicKit.h"

/**通过不同的排行类型, 实例视图控制器*/
@interface ChartsViewController : UIViewController
@property(nonatomic, strong,readonly) ResponseRoot *root;

-(instancetype)initWithResponseRoot:(ResponseRoot*) root;
@end
