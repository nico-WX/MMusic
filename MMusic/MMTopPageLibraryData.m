//
//  MMTopPageLibraryData.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/29.
//  Copyright © 2018 com.😈. All rights reserved.
//


#import "MMMyMusicPageViewController.h"

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

        _modelControllers = @[@{@"iCloud":iCloud},@{@"Local":local},];
        _cacheViewControllers = [NSMutableArray array];
    }
    return self;
}

# pragma mark - overwrite superClass method

- (NSInteger)numberOfItemsInSection:(NSUInteger)section{
    return self.modelControllers.count;
}

- (NSString *)titleWhitIndex:(NSInteger)index{
    NSDictionary<NSString*,MMModelController*> *dict = [self.modelControllers objectAtIndex:index];
    return [[dict allKeys] firstObject];
}


- (NSUInteger)indexOfViewController:(UIViewController *)viewController{
    MMMyMusicPageViewController *pageVC = (MMMyMusicPageViewController*)viewController;
    for (NSDictionary<NSString*,MMModelController*> *dict in self.modelControllers) {
        if (dict.allValues.firstObject == pageVC.modelController) {
            return [_modelControllers indexOfObject:dict];
        }
    }
    return NSNotFound;
}

- (UIViewController*)viewControllerAtIndex:(NSUInteger)index{
  
    //没有内容 , 或者大于内容数量  直接返回nil
    if (self.modelControllers.count == 0 || index > self.modelControllers.count) return nil;

    //查找缓存
    if (index < self.cacheViewControllers.count) {
        return [self.cacheViewControllers objectAtIndex:index];
    }

    //缓存中无, 创建并添加到缓存, 并返回
    NSDictionary<NSString*,MMModelController*> *dict = [self.modelControllers objectAtIndex:index];
    NSString *title = [dict allKeys].firstObject;
    MMModelController *data = [dict allValues].firstObject;

    MMMyMusicPageViewController *myVC = [[MMMyMusicPageViewController alloc] initWithDataSourceModel:data];
    [myVC setTitle:title];
    [self.cacheViewControllers addObject:myVC];
    return myVC;
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
    if (index==self.modelControllers.count) return nil;
    return [self viewControllerAtIndex:index];
}


@end
