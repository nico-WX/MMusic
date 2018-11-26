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
@property(nonatomic, strong, readonly)NSArray<NSDictionary<NSString*,ResponseRoot*>*> *searchResults; //搜索结果数据
@property(nonatomic, strong, readonly)NSArray<NSString*> *hints;    //搜索提示数据


/**
 搜索提示

 @param index 数据下标
 @return 提示字符串
 */
- (NSString*)hintTextForIndex:(NSInteger)index;

/**
 搜索结果分页内容

 @param index 页下标
 @return 搜索结果响应数据
 */
- (NSDictionary<NSString*,ResponseRoot*> *)searchResultsForIndex:(NSInteger)index;

/**
 获取搜索提示数据

 @param term 关键字
 @param completion 消息接收者
 */
- (void)searchHintForTerm:(NSString*)term complectin:(void(^)(MMSearchData* searchData))completion;

- (NSString*)pageTitleForIndex:(NSInteger)index;
/**
 搜索指定文本

 @param term 搜索文本
 @param completion 消息接受者
 */
- (void)searchDataForTemr:(NSString*)term completion:(void(^)(MMSearchData* searchData))completion;

- (UIViewController*)viewControllerAtIndex:(NSUInteger)index;
- (NSUInteger)indexOfViewController:(UIViewController*)viewController;
@end


NS_ASSUME_NONNULL_END
