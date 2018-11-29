//
//  MMLibraryData.h
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/29.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^Completion)(BOOL success);

@interface MMLibraryData : NSObject<UIPageViewControllerDataSource>
@property(nonatomic, strong, readonly)NSArray<NSDictionary<NSString*,ResponseRoot*> *> *results;

- (void)requestAllLibraryResource:(Completion)completion;

- (NSString*)titleWhitIndex:(NSInteger)index;
- (NSUInteger)indexOfViewController:(UIViewController*)viewController;
- (UIViewController*)viewControllerAtIndex:(NSUInteger)index;
@end

NS_ASSUME_NONNULL_END
