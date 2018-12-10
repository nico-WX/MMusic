//
//  MMLocalLibraryData.h
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/30.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@class MPMediaItem;
@interface MMLocalLibraryData : NSObject<UIPageViewControllerDataSource>

/**
 本地所有数据
 */
@property(nonatomic, strong, readonly) NSArray<NSDictionary<NSString*,NSArray<MPMediaItem*>*>*> *results;


/**
 加载数据

 @param completion 加载结果回调
 */
- (void)requestAllData:(void(^)(BOOL success))completion;


/**
 结果分页Title

 @param index 分页下标
 @return title
 */
- (NSString*)titleWhitIndex:(NSInteger)index;

/**
 指定视图控制器下标

 @param viewController 目标控制器
 @return 控制器在分页中的下标
 */
- (NSUInteger)indexOfViewController:(UIViewController*)viewController;

/**
 获取指定下标的视图控制器

 @param index 下标
 @return 目标控制器
 */
- (UIViewController*)viewControllerAtIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
