//
//  MMTopPageLibraryData.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/29.
//  Copyright © 2018 com.😈. All rights reserved.
//


#import "MMLocalLibraryViewController.h"
#import "MMCloudLibraryViewController.h"

#import "MMTopPageLibraryData.h"
#import "MMLibraryData.h"
#import "MMLocalLibraryData.h"

@interface MMTopPageLibraryData ()
//  本地和云音乐两个PageViewController
@property(nonatomic, strong) NSArray<NSDictionary<NSString*,id>*> *controllers;
@property(nonatomic, strong) NSMutableArray *cacheViewControllers;
@end

@implementation MMTopPageLibraryData

- (instancetype)init{
    if (self= [super init]) {
        MMLibraryData *iCloud = [[MMLibraryData alloc] init];
        MMLocalLibraryData *local = [[MMLocalLibraryData alloc] init];
        _controllers = @[@{@"iCloud":iCloud},@{@"local":local}];
        _cacheViewControllers = [NSMutableArray array];

    }
    return self;
}



# pragma - mark help method
//返回控制器对应的下标
- (NSUInteger)indexOfViewController:(UIViewController*)viewController {
    for (NSDictionary<NSString*,id> *dict in _controllers) {
        if ([viewController isKindOfClass:[MMLocalLibraryViewController class]]) {
            MMLocalLibraryViewController *localVC = (MMLocalLibraryViewController*)viewController;
            MMLocalLibraryData *data = localVC.localLibraryData;

            if ([[dict allValues] firstObject] == data) {
                return [_controllers indexOfObject:dict];
            }
        }
        if ([viewController isKindOfClass:[MMCloudLibraryViewController  class]]) {
            MMCloudLibraryViewController *iCloudVC = (MMCloudLibraryViewController*)viewController;
            MMLibraryData *data = iCloudVC.iCloudLibraryData;
            if ([[dict allValues] firstObject] == data) {
                return [_controllers indexOfObject:dict];
            }
        }
    }

    return NSNotFound;
}

//按下标, 获取控制器
- (UIViewController*)viewControllerAtIndex:(NSUInteger)index{
    //没有内容 , 或者大于内容数量  直接返回nil
    if (self.controllers.count == 0 || index > self.controllers.count) return nil;

    NSDictionary<NSString*,id> *dict = [self.controllers objectAtIndex:index];
    NSString *title = [dict allKeys].firstObject;
    id data = [dict allValues].firstObject;

    //查找创建过的VC
    for (UIViewController *vc in self.cacheViewControllers) {
        if (vc.responseRoot == root) {
            return vc;
        }
    }

    //数组中没有创建过的控制器, 创建新的,并添加到数组
    MMSearchContentViewController *contentVC = [[MMSearchContentViewController alloc] initWithResponseRoot:root];
    [contentVC setTitle:title];
    [self.cacheViewControllers addObject:contentVC]; //添加缓存
    return contentVC;
    return nil;
}

//#pragma mark - UIPageViewControllerDataSource
////返回左边控制器
//-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
//    MMSearchContentViewController *resultsVC = (MMSearchContentViewController*) viewController;
//
//    NSUInteger index = [self indexOfViewController:resultsVC];
//    if (index == 0 || index == NSNotFound) return nil;
//    index--;
//    return [self viewControllerAtIndex:index];
//}
//
////返回右边控制器
//-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
//    MMSearchContentViewController *resultsVC = (MMSearchContentViewController*) viewController;
//    NSUInteger index = [self indexOfViewController:resultsVC];
//    if (index== NSNotFound) return nil;
//
//    index++;
//    if (index==self.searchResults.count) return nil;
//    return [self viewControllerAtIndex:index];
//}


@end
