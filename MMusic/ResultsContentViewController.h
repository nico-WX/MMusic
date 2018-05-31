//
//  ResultsContentViewController.h
//  MMusic
//
//  Created by Magician on 2018/5/22.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ResponseRoot;

@interface ResultsContentViewController : UIViewController
@property(nonatomic, strong,readonly) UITableView *tableView;
@property(nonatomic,strong,readonly) ResponseRoot *responseRoot;
-(instancetype)initWithResponseRoot:(ResponseRoot*) responseRoot;
@end