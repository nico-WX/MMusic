//
//  Library+Rating.h
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/11.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import "Library.h"

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSUInteger, RTRatingType){
    //catalog
    RTCatalogAlbums,
    RTCatalogMusicVideos,
    RTCatalogPlaylists,
    RTCatalogSongs,
    RTCatalogStations,

    //library
    RTLibraryMusicVideos,
    RTLibraryPlaylists,
    RTLibrarySongs
};

@interface Library (Rating)


/**
 添加Rating

 @param identifier 资源identifier
 @param type 目录类型
 @param callBack 回调处理
 */
- (void)addRatingToCatalogWith:(NSString*)identifier type:(RTRatingType)type responseHandle:(RequestCallBack)callBack;


/**
 删除Rating

 @param identifier 资源identifier
 @param type 目录类型
 @param callBack 回调
 */
- (void)deleteRatingForCatalogWith:(NSString*)identifier type:(RTRatingType)type responseHandle:(RequestCallBack)callBack;


/**
 获取Rating

 @param identifier 资源id
 @param type 目录类型
 @param callBack 回调
 */
- (void)requestRatingForCatalogWith:(NSString*)identifier type:(RTRatingType)type responseHandle:(RequestCallBack)callBack;
@end

NS_ASSUME_NONNULL_END
