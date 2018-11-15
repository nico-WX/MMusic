//
//  DetailViewController.h
//  MMusic
//
//  Created by Magician on 2018/3/9.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Resource;
@class DetailHeaderView;

@class DetailViewController;

@protocol DetailViewControllerDelegate <NSObject>

- (void)detailViewControllerDidDismiss:(DetailViewController*)detailVC;

@end

@interface DetailViewController : UIViewController
@property(nonatomic, weak)id<DetailViewControllerDelegate> dismissDelegate;


/**通过Resource 初始化*/
- (instancetype) initWithResource:(Resource*) resource;
/**通过songs root响应体,直接初始化, 没有头视图*/
//- (instancetype) initWithResponseRoot:(ResponseRoot*) responseRoot;

- (instancetype)initWithAlbum:(Album*)album;
- (instancetype)initWithPlaylist:(Playlist*)playlist;
@end
