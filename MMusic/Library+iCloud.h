//
//  Library+iCloud.h
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/11.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import "Library.h"

NS_ASSUME_NONNULL_BEGIN

@interface Library (iCloud)

/**
添加指定的资源到音乐库

@param ids 资源Ids
@param type 资源类型
@param handle 处理结果
*/
- (void)addResourceToLibraryForIdentifiers:(NSArray<NSString*>*)ids byType:(AddType) type callBack:(RequestCallBack)handle;

/**
 创建新的音乐库播放列表

 @param json 请求体字典
 */
- (void)createNewLibraryPlaylistsForJsonPlayload:(NSDictionary*)json callBack:(RequestCallBack)handle;


/**
 添加歌曲到个人播放列表

 @param identifier  个人播放列表id
 @param tracks      song 播放参数字典列表
 @param handle      处理结果
 */
- (void)addTracksToLibraryPlaylists:(NSString *)identifier tracks:(NSArray<NSDictionary*>*)tracks callBack:(RequestCallBack)handle;

@end

NS_ASSUME_NONNULL_END
