//
//  MMSearchData.h
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/24.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ResponseRoot;

@interface MMSearchData : NSObject<UIPageViewControllerDataSource>
@property(nonatomic, strong, readonly)NSArray<NSString*> *searchHinstory;   // 搜索历史
@property(nonatomic, strong, readonly)NSArray<NSDictionary<NSString*,ResponseRoot*>*> *searchResults; //搜索结果数据
@property(nonatomic, strong, readonly)NSArray<NSString*> *searchHints;    //搜索提示数据

/**
 节title

 @param index 节下标
 @return title
 */
- (NSString*)pageTitleForIndex:(NSInteger)index;

/**
 搜索指定文本

 @param term 搜索文本
 @param completion 消息接受者
 */
- (void)searchDataForTemr:(NSString*)term completion:(void(^)(BOOL success))completion;


/**分页控制器中的 对应下标子控制器*/
- (UIViewController*)viewControllerAtIndex:(NSUInteger)index;
/**控制器的下标*/
- (NSUInteger)indexOfViewController:(UIViewController*)viewController;
@end



@interface MMSearchData (Hints)
/**
 获取搜索提示数据

 @param term 关键字
 @param completion 消息接收者
 */
- (void)searchHintForTerm:(NSString*)term complectin:(void(^)(BOOL success))completion;

@end



NS_ASSUME_NONNULL_END
