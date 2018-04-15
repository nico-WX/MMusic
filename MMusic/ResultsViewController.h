//
//  ResultsViewController.h
//  MMusic
//
//  Created by Magician on 2018/4/9.
//  Copyright © 2018年 com.😈. All rights reserved.
//


#import <UIKit/UIKit.h>
@class Artist;

/**选中的某个艺人 搜索结果, 其他类型搜索直接可以在候选菜单操作*/
@interface ResultsViewController : UIViewController
-(instancetype)initWithArtist:(Artist*) artist;
@end
