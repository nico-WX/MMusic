//
//  MMSearchData.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/24.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import "MMSearchData.h"
#import "ResponseRoot.h"
#import "MMSearchContentViewController.h"

@interface MMSearchData ()
@property(nonatomic, strong)NSArray<NSDictionary<NSString*,ResponseRoot*>*> *searchResults;
@property(nonatomic, strong)NSArray<NSString*> *hints;

@property(nonatomic, strong)NSMutableArray<MMSearchContentViewController*> *cacheViewControllers;
@end

@implementation MMSearchData
- (instancetype)init{
    if (self = [super init]) {
        _cacheViewControllers = [NSMutableArray array];
    }
    return self;
}

-(NSInteger)sectionCount{
    return self.searchResults.count;
}
-(NSInteger)hintsCount{
    return self.hints.count;
}

- (NSString *)hintTextForIndex:(NSInteger)index{
    return [self.hints objectAtIndex:index];
}

-(NSDictionary<NSString *,ResponseRoot *> *)searchResultsForIndex:(NSInteger)index{
    return [self.searchResults objectAtIndex:index];
}

- (NSString*)pageTitleForIndex:(NSInteger)index{
    NSDictionary<NSString*,ResponseRoot*> *dict = [self.searchResults objectAtIndex:index];
    return [dict allKeys].firstObject;
}

- (void)searchDataForTemr:(NSString *)term completion:(void (^)(MMSearchData * _Nonnull))completion{
    [[MusicKit new].catalog searchForTerm:term callBack:^(NSDictionary *json, NSHTTPURLResponse *response) {
        json = [json valueForKey:@"results"];
        //检查结果返回空结果字典
        if (json.allKeys.count != 0)  {

            NSMutableArray<NSDictionary<NSString*,ResponseRoot*>*> *resultsList = [NSMutableArray array];
            //解析字典
            [json enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                ResponseRoot *root = [ResponseRoot instanceWithDict:obj];
                [resultsList addObject:@{(NSString*)key:root}];
            }];
            self.searchResults = resultsList;
            //移除旧控制器
            if (self.cacheViewControllers.count >0) {
                [self.cacheViewControllers removeAllObjects];
            }
        }
        
        if (completion) {
            completion(self);
        }
    }];
}

- (void)searchHintForTerm:(NSString *)term complectin:(void (^)(MMSearchData * _Nonnulll))completion{
    [MusicKit.new.catalog searchHintsForTerm:term callBack:^(NSDictionary *json, NSHTTPURLResponse *response) {
        if ([json valueForKeyPath: @"results.terms"]) {
            self.hints = [json valueForKeyPath:@"results.terms"];
            if (completion) {
                completion(self);
            }
        }
    }];
}

# pragma - mark help method
//返回控制器对应的下标
- (NSUInteger)indexOfViewController:(UIViewController*)viewController {
    for (NSDictionary<NSString*,ResponseRoot*> *dict in self.searchResults) {
        if ([viewController isKindOfClass:MMSearchContentViewController.class]) {
            MMSearchContentViewController *scVC = (MMSearchContentViewController*)viewController;
            if (scVC.responseRoot == dict.allValues.firstObject) {
                return [self.searchResults indexOfObject:dict];
            }
        }
    }
    return NSNotFound;
}

//按下标, 获取控制器
- (UIViewController*)viewControllerAtIndex:(NSUInteger)index{
    //没有内容 , 或者大于内容数量  直接返回nil
    if (self.searchResults.count == 0 || index > self.searchResults.count) return nil;

    NSDictionary<NSString*,ResponseRoot*> *dict = [self.searchResults objectAtIndex:index];
    NSString *title = [dict allKeys].firstObject;
    ResponseRoot *root = [dict allValues].firstObject;

    //查找创建过的VC
    for (MMSearchContentViewController *vc in self.cacheViewControllers) {
        if (vc.responseRoot == root) {
            return vc;
        }
    }

    //数组中没有创建过的控制器, 创建新的,并添加到数组
    MMSearchContentViewController *contentVC = [[MMSearchContentViewController alloc] initWithResponseRoot:root];
    [contentVC setTitle:title];
    [self.cacheViewControllers addObject:contentVC];
    return contentVC;
}

#pragma mark - UIPageViewControllerDataSource
//返回左边控制器
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    MMSearchContentViewController *resultsVC = (MMSearchContentViewController*) viewController;

    NSUInteger index = [self indexOfViewController:resultsVC];
    if (index == 0 || index == NSNotFound) return nil;
    index--;
    return [self viewControllerAtIndex:index];
}

//返回右边控制器
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    MMSearchContentViewController *resultsVC = (MMSearchContentViewController*) viewController;
    NSUInteger index = [self indexOfViewController:resultsVC];
    if (index== NSNotFound) return nil;

    index++;
    if (index==self.searchResults.count) return nil;
    return [self viewControllerAtIndex:index];
}

@end
