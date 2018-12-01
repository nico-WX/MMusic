//
//  MMTopPageLibraryData.h
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/29.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// 一级分页 控制
@interface MMTopPageLibraryData : NSObject<UIPageViewControllerDataSource>
/**mymusic 顶部ICloud 和 Local 分页*/
@property(nonatomic, strong, readonly) NSArray<NSDictionary<NSString*,id>*> *controllers;

- (NSString*)titleWhitIndex:(NSInteger)index;
- (NSUInteger)indexOfViewController:(UIViewController*)viewController;
- (UIViewController*)viewControllerAtIndex:(NSUInteger)index;
@end

NS_ASSUME_NONNULL_END
