//
//  MMLibraryData.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/29.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import "MMLibraryData.h"
#import "ResponseRoot.h"
#import "MMSearchContentViewController.h"

#import <MediaPlayer/MediaPlayer.h>

@interface MMLibraryData ()
@property(nonatomic, strong) NSMutableArray<UIViewController*> *cacheViewControllers;

@end
@implementation MMLibraryData
- (instancetype)init {
    if (self = [super init]) {
        _results = [NSArray array];
        _cacheViewControllers = [NSMutableArray array];
    }
    return self;
}

- (NSString *)titleWhitIndex:(NSInteger)index{
    return [[[self.results objectAtIndex:index] allKeys] firstObject];
}

- (void)requestAllLibraryResource:(Completion)completion{
    //music-videos
    //playlists
    //albums
    //songs

    NSMutableArray<NSDictionary<NSString*,ResponseRoot*>*> *array = [NSMutableArray array];

    void(^callBack)(NSDictionary<NSString *,ResponseRoot *> *resource) = ^(NSDictionary<NSString *,ResponseRoot *> *resource) {
        if (resource) {
            [array addObject:resource];
            self->_results = array;
            if (completion) {
                completion(self->_results.count > 0);
            }
        }
    };
    [self requestAllAlbums:callBack];
    [self requestAllPlaylists:callBack];
    [self requestAllMusicVideos:callBack];
    [self requestAllLibrarySongs:callBack];
}
- (void)requestAllAlbums:(void(^)(NSDictionary<NSString*,ResponseRoot*> *resource))completion{
    [MusicKit.new.library resource:@[] byType:CLibraryAlbums callBack:^(NSDictionary *json, NSHTTPURLResponse *response) {
        if (json) {
            ResponseRoot *root = [[ResponseRoot alloc] initWithDict:json];
            completion(@{@"albums":root});
        }else{
            completion(nil);
        }
    }];
}
- (void)requestAllPlaylists:(void(^)(NSDictionary<NSString*,ResponseRoot*> *resource))completion{
    [MusicKit.new.library resource:nil byType:CLibraryPlaylists callBack:^(NSDictionary *json, NSHTTPURLResponse *response) {
        if (json) {
            ResponseRoot *root = [[ResponseRoot alloc] initWithDict:json];
            completion(@{@"playlists":root});
        }else{
            completion(nil);
        }
    }];
}
- (void)requestAllMusicVideos:(void(^)(NSDictionary<NSString*,ResponseRoot*> *resource))completion{
    [MusicKit.new.library resource:nil byType:CLibraryMusicVideos callBack:^(NSDictionary *json, NSHTTPURLResponse *response) {
        if (json) {
            ResponseRoot *root = [[ResponseRoot alloc] initWithDict:json];
            completion(@{@"music-videos":root});
        }else{
            completion(nil);
        }
    }];
}


- (void)requestAllLibrarySongs:(void(^)(NSDictionary<NSString*,ResponseRoot*> *resource))completion{
    [MusicKit.new.library resource:nil byType:CLibrarySongs callBack:^(NSDictionary *json, NSHTTPURLResponse *response) {
        if (json) {
            ResponseRoot *root = [[ResponseRoot alloc] initWithDict:json];
            completion(@{@"songs":root});
        }else{
            completion(nil);
        }
    }];
}


# pragma - mark help method
//返回控制器对应的下标
- (NSUInteger)indexOfViewController:(UIViewController*)viewController {
    for (NSDictionary<NSString*,ResponseRoot*> *dict in self.results) {
        if ([viewController isKindOfClass:MMSearchContentViewController.class]) {
            MMSearchContentViewController *scVC = (MMSearchContentViewController*)viewController;
            if (scVC.responseRoot == dict.allValues.firstObject) {
                return [self.results indexOfObject:dict];
            }
        }
    }
    return NSNotFound;
}

//按下标, 获取控制器
- (UIViewController*)viewControllerAtIndex:(NSUInteger)index{
    //没有内容 , 或者大于内容数量  直接返回nil
    if (self.results.count == 0 || index > self.results.count) return nil;

    NSDictionary<NSString*,ResponseRoot*> *dict = [self.results objectAtIndex:index];
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
    [self.cacheViewControllers addObject:contentVC]; //添加缓存
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
    if (index==self.results.count) return nil;
    return [self viewControllerAtIndex:index];
}


@end
