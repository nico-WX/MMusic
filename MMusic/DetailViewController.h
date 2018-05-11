//
//  DetailViewController.h
//  MMusic
//
//  Created by Magician on 2018/3/9.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Resource;
@class HeaderView;

@interface DetailViewController : UIViewController
/**头视图*/
@property(nonatomic, strong) HeaderView *header;
/**表视图*/
@property(nonatomic, strong) UITableView *tableView;

/**直接通过专辑,或者播放列表初始化*/
- (instancetype) initWithResource:(Resource*) resource;

@end
