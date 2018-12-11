//
//  MMTopPageLibraryData.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/29.
//  Copyright © 2018 com.😈. All rights reserved.
//


#import "MMMyMusicPageViewController.h"

//#import "MMLocalLibraryViewController.h"
//#import "MMCloudLibraryViewController.h"

#import "MMTopPageLibraryData.h"
#import "MMLibraryData.h"
#import "MMLocalLibraryData.h"

@interface MMTopPageLibraryData ()
//  本地和云音乐两个PageViewController
@property(nonatomic, strong) NSMutableArray<UIViewController*> *cacheViewControllers;
@end

@implementation MMTopPageLibraryData

- (instancetype)init{
    if (self= [super init]) {
        MMLibraryData *iCloud = [[MMLibraryData alloc] init];
        MMLocalLibraryData *local = [[MMLocalLibraryData alloc] init];
        _controllers = @[@{@"iCloud":iCloud},@{@"Local":local},];
        _cacheViewControllers = [NSMutableArray array];
    }
    return self;
}

- (NSString *)titleWhitIndex:(NSInteger)index{
    return [[[_controllers objectAtIndex:index] allKeys] firstObject];
}

# pragma - mark help method
//返回控制器对应的下标

- (NSUInteger)indexOfViewController:(UIViewController *)viewController{

    MMMyMusicPageViewController *pageVC = (MMMyMusicPageViewController*)viewController;
    for (NSDictionary<NSString*,MMModelController*> *dict in self.controllers) {
        if (dict.allValues.firstObject == pageVC.modelController) {
            return [_controllers indexOfObject:dict];
        }
    }
    return NSNotFound;
}

//按下标, 获取控制器
- (UIViewController*)viewControllerAtIndex:(NSUInteger)index{
  
    //没有内容 , 或者大于内容数量  直接返回nil
    if (self.controllers.count == 0 || index > self.controllers.count) return nil;

    
    if (index < self.cacheViewControllers.count) {
        return [self.cacheViewControllers objectAtIndex:index];
    }

    NSDictionary<NSString*,MMModelController*> *dict = [self.controllers objectAtIndex:index];
    NSString *title = [dict allKeys].firstObject;
    MMModelController *data = [dict allValues].firstObject;

    MMMyMusicPageViewController *myVC = [[MMMyMusicPageViewController alloc] initWithDataSourceModel:data];
//    [myVC.pageViewController setDataSource:data];
    [myVC setTitle:title];
    [self.cacheViewControllers addObject:myVC];

    return myVC;


//    if ([data isKindOfClass:[MMLibraryData class]]) {
//        MMCloudLibraryViewController *vc = [[MMCloudLibraryViewController alloc] initWithICloudLibraryData:data];
//        [vc setTitle:title];
//        [_cacheViewControllers addObject:vc];
//        return vc;
//    }
//    if ([data isKindOfClass:[MMLocalLibraryData class]]) {
//        MMLocalLibraryViewController *vc = [[MMLocalLibraryViewController alloc] initWithLocalLibraryData:data];
//        [vc setTitle:title];
//        [_cacheViewControllers addObject:vc];
//        return vc;
//    }
//    return nil;
}

#pragma mark - UIPageViewControllerDataSource
//返回左边控制器
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    NSUInteger index = [self indexOfViewController:viewController];
    if (index == 0 || index == NSNotFound) return nil;
    index--;
    return [self viewControllerAtIndex:index];
}

//返回右边控制器
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{

    NSUInteger index = [self indexOfViewController:viewController];
    if (index== NSNotFound) return nil;

    index++;
    if (index==self.controllers.count) return nil;
    return [self viewControllerAtIndex:index];
}


@end
