//
//  TodayCollectionViewCell.h
//  MMusic
//
//  Created by Magician on 2017/12/26.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Resource;

@interface TodayCollectionViewCell : UICollectionViewCell
@property(nonatomic, readonly, strong) NSArray<Resource*> *data;
@property(nonatomic, strong) Resource *resource;
@property(nonatomic, strong) NSString *title;
@end
