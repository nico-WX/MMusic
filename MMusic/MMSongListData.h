//
//  MMSongListData.h
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/23.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class Resourcel;

/**请求歌曲列表*/
@interface MMSongListData : NSObject

- (NSInteger)songCount;
- (Song*)songWithIndex:(NSInteger)index;
- (NSArray<Song*> *)songList;

- (void)loadNextPageWithComplection:(void(^)(BOOL success))completion;


/**
 通过Resource请求资源
 @param resource resource 对象
 @param completion 数据返回回调
 */
- (void)resourceDataWithResource:(Resource*)resource completion:(void(^)(BOOL success))completion;

- (void)songListDataWithResponseRoot:(ResponseRoot*)root completion:(void(^)(BOOL ))completion;
@end

NS_ASSUME_NONNULL_END
