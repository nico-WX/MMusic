//
//  MMLocalLibraryData.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/30.
//  Copyright © 2018 com.😈. All rights reserved.
//


#import <StoreKit/StoreKit.h>
#import <MediaPlayer/MediaPlayer.h>

#import "MMLibraryContentViewController.h"
#import "MMLocalLibraryData.h"

@interface MMLocalLibraryData ()
@property(nonatomic, strong) NSMutableArray *cacheViewControllers;
@end


@implementation MMLocalLibraryData

- (instancetype)init{
    if (self = [super init]) {
        _cacheViewControllers = [NSMutableArray array];
    }
    return self;
}

- (void)importDataWithCompletion:(void (^)(BOOL))completion{
    [self requestAllData:completion];
}

- (void)requestAllData:(void (^)(BOOL))completion{
    [SKCloudServiceController requestAuthorization:^(SKCloudServiceAuthorizationStatus status) {
        switch (status) {
            case SKCloudServiceAuthorizationStatusAuthorized:{
                /**

                 */
                MPMediaQuery *playlist = [MPMediaQuery playlistsQuery];
                MPMediaQuery *album = [MPMediaQuery albumsQuery];
                MPMediaQuery *artist = [MPMediaQuery artistsQuery];
                MPMediaQuery *song = [MPMediaQuery songsQuery];
                MPMediaQuery *podcasts = [MPMediaQuery podcastsQuery];

                NSMutableArray<NSDictionary<NSString*,NSArray<MPMediaItem*> *>*> *temp = [NSMutableArray array];

                [playlist setGroupingType:MPMediaGroupingGenre];
                [temp addObject:@{@"playlist":playlist.items}];

                [album setGroupingType:MPMediaGroupingAlbumArtist];
                [temp addObject:@{@"album":album.items}];

                [artist setGroupingType:MPMediaGroupingTitle];
                [temp addObject:@{@"artist":artist.items}];

                [song setGroupingType:MPMediaGroupingArtist];
                [temp addObject:@{@"song":song.items}];

                [podcasts setGroupingType:MPMediaGroupingPodcastTitle];
                [temp addObject:@{@"podcasts":podcasts.items}];


//                [podcasts setGroupingType:MPMediaGroupingPodcastTitle];
//                for (MPMediaItemCollection *item in podcasts.collections) {
//                    NSLog(@"***********************************************");
//                    for (MPMediaItem *i in item.items) {
//                       // NSLog(@"title === %@",i.title);
//                        NSLog(@"pod ------>%@",i.podcastTitle);
//                    }
//                }

                self->_results = temp;
                if (completion) {
                    completion(self->_results.count > 0);
                }
            }
                break;

            default:
                break;
        }
    }];
}


- (NSInteger)numberOfItemsInSection:(NSUInteger)section{
    return self.results.count;
}
- (NSString *)titleWhitIndex:(NSInteger)index{
    return [[[self.results objectAtIndex:index] allKeys] firstObject];
}

# pragma - mark help method
//返回控制器对应的下标
- (NSUInteger)indexOfViewController:(UIViewController*)viewController {
    for (NSDictionary<NSString*,NSArray<MPMediaItem*> *> *dict in self.results) {
        if ([viewController isKindOfClass:MMLibraryContentViewController.class]) {
            MMLibraryContentViewController *scVC = (MMLibraryContentViewController*)viewController;
            if (scVC.items == [dict allValues].firstObject) {
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

    NSDictionary<NSString*,NSArray<MPMediaItem*>*> *dict = [self.results objectAtIndex:index];
    NSString *title = [dict allKeys].firstObject;
    NSArray<MPMediaItem*> *items = [dict allValues].firstObject;

    //查找创建过的VC
    for (MMLibraryContentViewController * vc in self.cacheViewControllers) {
        if (vc.items == items) {
            return vc;
        }
    }

    //数组中没有创建过的控制器, 创建新的,并添加到数组
    MMLibraryContentViewController *contentVC = [[MMLibraryContentViewController alloc] initWithMediaItems:items];
    [contentVC setTitle:title];
    [self.cacheViewControllers addObject:contentVC]; //添加缓存
    return contentVC;
}

#pragma mark - UIPageViewControllerDataSource
//返回左边控制器
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    MMLibraryContentViewController *resultsVC = (MMLibraryContentViewController*) viewController;

    NSUInteger index = [self indexOfViewController:resultsVC];
    if (index == 0 || index == NSNotFound) return nil;
    index--;
    return [self viewControllerAtIndex:index];
}

//返回右边控制器
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    MMLibraryContentViewController *resultsVC = (MMLibraryContentViewController*) viewController;
    NSUInteger index = [self indexOfViewController:resultsVC];
    if (index== NSNotFound) return nil;

    index++;
    if (index==self.results.count) return nil;
    return [self viewControllerAtIndex:index];
}



@end
