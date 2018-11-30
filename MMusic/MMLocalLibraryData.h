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

@property(nonatomic, strong, readonly) NSArray<NSDictionary<NSString*,NSArray<MPMediaItem*>*>*> *results;

- (void)requestAllData:(void(^)(BOOL success))completion;

- (NSString*)titleWhitIndex:(NSInteger)index;
- (NSUInteger)indexOfViewController:(UIViewController*)viewController;
- (UIViewController*)viewControllerAtIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
