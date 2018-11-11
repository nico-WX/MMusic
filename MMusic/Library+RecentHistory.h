//
//  Library+RecentHistory.h
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/11.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import "Library.h"

NS_ASSUME_NONNULL_BEGIN

@interface Library (RecentHistory)

/**
 获取重复播放高的内容

 @param handle 数据回调
 */
- (void)heavyRotationContentInCallBack:(RequestCallBack)handle;

/**
 最近播放的资源

 @param handle 数据回调
 */
- (void)recentlyPlayedInCallBack:(RequestCallBack)handle;

/**
 最近播放的无线电台

 @param handle 数据回调
 */
- (void)recentStationsInCallBack:(RequestCallBack)handle;

/**
 最近添加到音乐库的资源

 @param handle 数据回调
 */
- (void)recentlyAddedToLibraryInCallBack:(RequestCallBack)handle;

@end

NS_ASSUME_NONNULL_END
