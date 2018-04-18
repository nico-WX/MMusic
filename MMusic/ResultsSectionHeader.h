//
//  ResultsSectionView.h
//  MMusic
//
//  Created by Magician on 2018/4/10.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VBFPopFlatButton.h>

/**搜索结果头视图*/
@interface ResultsSectionHeader : UITableViewHeaderFooterView
@property(nonatomic, strong) UILabel *title;
@property(nonatomic, strong) VBFPopFlatButton *more;
@end
