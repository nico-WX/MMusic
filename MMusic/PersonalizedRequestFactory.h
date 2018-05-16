//
//  PersonalizedRequestFactory.h
//  MMusic
//
//  Created by Magician on 2017/11/25.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>



/**个性化请求类型*/
typedef NS_ENUM(NSUInteger, PersonalizedType){
    /**高度重复播放*/
    PersonalizedRotationContentType,
    /**最近播放资源*/
    PersonalizedRecentlyPlayedType,
    /**最近播放电台*/
    PersonalizedRecentStationsType,
    /**默认推荐*/
    PersonalizedDefaultRecommendationsType,
    /**推荐专辑*/
    PersonalizedAlbumRecommendationsType,
    /**推荐播放列表*/
    PersonalizedPlaylistRecommendationsType,
    /**单张推荐*/
    PersonalizedRecommendationType,
    /**多张推荐*/
    PersonalizedMultipleRecommendationType,
};

/**管理评价请求类型*/
typedef NS_ENUM(NSUInteger, RatingsType){
    /**获取单张专辑评价*/
    GetAlbumRatingType,
    /**获取多张专辑评价*/
    GetMultipleAlbumRatingsType,
    /**增加专家评价*/
    AddAlbumRatingsType,
    /**删除一张专辑的评价*/
    DeleteAlbumRatingsType,

    /**获取一张MV评价*/
    GetMusicVideoRatingsType,
    /**获取多张MV评价*/
    GetMultipleMusicVideoRatingsType,
    /**增加一张MV评价*/
    AddMusicVideoRatingsType,
    /**删除一张MV评价*/
    DeleteMusicVideoRatingsType,

    /**获取一张播放列表评价*/
    GetPlaylistRatingsType,
    /**获取多张播放列表评价*/
    GetMultiplePlaylistRatingsType,
    /**增加一张播放列表评价*/
    AddPlaylistRatingsType,
    /**删除播放列表评价*/
    DeletePlaylistRatingsType,

    /**获取一首歌曲评价*/
    GetSongRatingsType,
    /**获取多首歌曲评价*/
    GetMultipleSongRatingsType,
    /**增加一首歌曲评价*/
    AddSongRatingsType,
    /**删除一首歌曲评价*/
    DeleteSongRatingsType,

    /**获取一个电台的评价*/
    GetStationRatingsType,
    /**多个电台评价*/
    GetMultipleStationRatingsType,
    /**增加一个电台评价*/
    AddStationRatingsType,
    /**删除一个电台评价*/
    DeleteStationRatingsType,
};

/**个性化请求工厂*/
@interface PersonalizedRequestFactory : NSObject
/**根路径*/
@property(nonatomic,copy) NSString *rootPath;

/**
 创建个性化请求对象 注意:(单张推荐和多张推荐需要在ids中提供Identifier,其他请求设置空数组)
 @param type 请求资源的类型
 @param ids 资源identifier 列表
 @return 请求体
 */
-(NSURLRequest*) createRequestWithType:(PersonalizedType) type resourceIds:( NSArray<NSString*>* _Nullable ) ids;

/**
 评级管理请求
 @param type 请求类型
 @param ids 资源identifier 列表
 @return 请求体
 */
-(NSURLRequest*) createManageRatingsRequestWithType:(RatingsType) type resourceIds:( NSArray<NSString*> * _Nullable ) ids;

@end

#pragma mark - 获取库资源操作
/**获取库资源*/
@interface PersonalizedRequestFactory(FetchLirraryResource)

/**库资源类型*/
typedef NS_ENUM(NSUInteger, LibraryResourceType){
    LibraryResourceAlbums,
    LibraryResourceArtists,
    LibraryResourceMusicVideos,
    LibraryResourcePlaylists,
    LibraryResourceSongs
};

/**
 获取资源库内容

 @param type 获取的资源类型
 @param ids 资源标识, 传空为获取该类型的所有资源
 @return 请求体
 */
-(NSURLRequest*)fetchLibraryResourceWithType:(LibraryResourceType) type fromIds:(NSArray<NSString*>*) ids;
@end



#pragma mark - 管理库资源(增删)
@interface PersonalizedRequestFactory(ManagerLibrarySource)

/**
 操作类型

 - ManagerLibraryAddOperation: 增加
 - ManagerLibraryDeleteOperation: 删除
 */
typedef NS_ENUM(NSUInteger,ManagerLibraryOperation){
    ManagerLibraryAddOperation,
    ManagerLibraryDeleteOperation
};


/**
 管理库资源

 @param operation 操作(增加/删)
 @param type 资源类型
 @param identifier 资源标识
 @return 请求体
 */
-(NSURLRequest*) managerLibrarySourcesWithOperation:(ManagerLibraryOperation)operation resourceType:(LibraryResourceType) type andId:(NSString*) identifier;

@end



#pragma mark - 修改库播放列表
@interface PersonalizedRequestFactory(ModifyLibraryPlaylists)

/**
 修改播放列表操作
 - ModifyOperationCreateNewLibraryPlaylist: 创建新的播放列表
 - ModifyOperationReplaceLibraryPlaylistAttributes: 替换播放列表属性(名称/描叙)
 - ModifyOperationUpdateLibraryPlaylistAttributes: 更新播放列表属性
 - ModifyOperationAddTracksToLibraryPlaylist: 向播放例表添加Tracks
 - ModifyOperationReplaceTrackListForLibraryPlaylist: 替换播放列表Track

 */
typedef NS_ENUM(NSUInteger,ModifyOperationType){
    ModifyOperationCreateNewLibraryPlaylist,
    ModifyOperationReplaceLibraryPlaylistAttributes,
    ModifyOperationUpdateLibraryPlaylistAttributes,
    ModifyOperationAddTracksToLibraryPlaylist,
    ModifyOperationReplaceTrackListForLibraryPlaylist
};


/**
 删除模式

 - DeleteModeFirst: 第一个出现
 - DeleteModeLast: 最后一个出现
 - DeleteModeAll: 全部
 */
typedef NS_ENUM(NSUInteger,DeleteMode) {
    DeleteModeFirst,
    DeleteModeLast,
    DeleteModeAll
};

/**
 删除的Track 类型

 - DeleteLibrarySongsType: 歌曲类型
 - DeleteLibraryMusicVideosType: 音乐视频类型
 */
typedef NS_ENUM(NSUInteger, DeleteTrackType){
    DeleteLibrarySongsType,
    DeleteLibraryMusicVideosType
};


/**
 修改列表

 @param type 操作类型
 @param playlistIdnetifier 播放列表标识
 @param jsonPlayload json数据
 @return 请求体
 */
-(NSURLRequest *) modifyLibraryPlaylistsWithOperation:(ModifyOperationType) type
                                               fromId:(NSString*) playlistIdnetifier
                                       andJSONPayload:(NSDictionary*) jsonPlayload;

/**
 删除播放列表中的track

 @param identifier 列表identifier
 @param type track类型
 @param deleteIdentifier track 标识
 @param mode 删除模式
 @return 请求体
 */
-(NSURLRequest*)deleteTracksFromLibraryPlaylistIdentifier:(NSString*)identifier
                                                    types:(DeleteTrackType)type
                                                      ids:(NSString*) deleteIdentifier
                                                     mode:(DeleteMode) mode;

@end




















