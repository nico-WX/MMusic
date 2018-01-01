//
//  RecommendDetailViewController.h
//  MMusic
//
//  Created by Magician on 2017/12/27.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Resource;

@interface RecommendDetailViewController : UICollectionViewController
/**推荐的资源*/
@property(nonatomic, strong) NSArray<Resource*> *data;
@end
