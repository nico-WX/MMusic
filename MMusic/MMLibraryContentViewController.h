//
//  MMLibraryContentViewController.h
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/30.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

NS_ASSUME_NONNULL_BEGIN

@interface MMLibraryContentViewController : UIViewController
@property(nonatomic, strong, readonly)NSArray<MPMediaItem*> *items;

- (instancetype)initWithMediaItems:(NSArray<MPMediaItem*>*)mediaItems;
//- (instancetype)initWithMediaCollections:(NSArray<MPMediaItemCollection *>*)itemCollection;

@end

NS_ASSUME_NONNULL_END
