//
//  MMDetailTopViewController.h
//  MMusic
//
//  Created by Magician on 2017/12/6.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Recommendation.h"

@interface MMDetailTopViewController : UICollectionViewController
@property(nonatomic, strong) Recommendation *recommendation;
/**将选择的数据逆传到父控制器*/
@property(nonatomic, strong) void(^selectedData)(Resource* resource);
@end
