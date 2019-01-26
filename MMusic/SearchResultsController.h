//
//  SearchResultsController.h
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/20.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SearchResultsController : UIViewController<UISearchResultsUpdating,UISearchControllerDelegate>

@property(nonatomic,strong,readonly) UITableView *searchResultsView;
@end

NS_ASSUME_NONNULL_END
