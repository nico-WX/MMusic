//
//  DetailViewController.h
//  MMusic
//
//  Created by Magician on 2018/3/9.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Resource;
@class DetailHeaderView;

@interface DetailViewController : UIViewController
/**表视图*/
@property(nonatomic, strong,readonly) UITableView *tableView;
/**直接通过专辑,或者播放列表初始化*/
- (instancetype) initWithResource:(Resource*) resource;
/**通过songs root响应体,直接初始化, 没有头视图*/
- (instancetype) initWithResponseRoot:(ResponseRoot*) responseRoot;

@end
