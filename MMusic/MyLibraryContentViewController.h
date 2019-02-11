//
//  MyLibraryContentViewController.h
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/27.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//@"本地歌曲",@"我喜欢的",@"专辑",@"歌曲",@"播放列表",@"广播"
typedef NS_ENUM(NSUInteger, LibraryContentType) {
    LibraryMyLikeSongType,
    LibraryAlbumType,
    LibrarySongType,
    LibraryPlaylistType,
    LibraryPodcastsType
};

@interface MyLibraryContentViewController : UIViewController
- (instancetype)initWithType:(LibraryContentType)type;
@end

NS_ASSUME_NONNULL_END
