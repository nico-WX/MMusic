//
//  SearchResultsController.h
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/20.
//  Copyright © 2019 com.😈. All rights reserved.
//
#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SearchResultsController : BaseViewController <UISearchResultsUpdating,UISearchControllerDelegate>

/**代理在主视图控制器中, 选中可以入栈导航栏*/
@property(nonatomic,strong,readonly) UITableView *searchResultsView;
@end

NS_ASSUME_NONNULL_END
