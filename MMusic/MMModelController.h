//
//  MMModelController.h
//  MMusic
//
//  Created by 🐙怪兽 on 2018/12/11.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MMModelController : NSObject<UIPageViewControllerDataSource>

- (void)importDataWithCompletion:(void(^)(BOOL success))completion;
- (NSInteger)numberOfItemsInSection:(NSUInteger)section;
- (NSString*)titleWhitIndex:(NSInteger)index;
- (NSUInteger)indexOfViewController:(UIViewController*)viewController;
- (UIViewController*)viewControllerAtIndex:(NSUInteger)index;
@end

NS_ASSUME_NONNULL_END
