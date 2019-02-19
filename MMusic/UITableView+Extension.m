//
//  UITableView+Extension.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/2/18.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "UITableView+Extension.h"

@implementation UITableView (Extension)

- (void)hiddenSurplusSeparator{
    self.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}
@end
