//
//  PersonalizedRequestFactory.h
//  MMusic
//
//  Created by Magician on 2017/11/25.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>


/**个性化请求工厂*/
@interface PersonalizedRequestFactory : NSObject

@end

#pragma mark - Fetch Library Resources (获取库资源操作)
/**
 获取库资源
 */
@interface PersonalizedRequestFactory(FetchLibraryResource)

/**
 库资源类型
 - LibraryResourceAlbums:       库专辑
 - LibraryResourceArtists:      库艺人
 - LibraryResourceMusicVideos:  库音乐视频
 - LibraryResourcePlaylists:    库播放列表
 - LibraryResourceSongs:        库歌曲
 */
typedef NS_ENUM(NSUInteger, LibraryResourceType){
    LibraryResourceAlbums,
    LibraryResourceArtists,
    LibraryResourceMusicVideos,
    LibraryResourcePlaylists,
    LibraryResourceSongs
};

/**
 获取资源库内容

 @param type    获取的资源类型
 @param ids     资源标识, 传空为获取该类型的所有资源
 @return        请求体
 */
-(NSURLRequest*)fetchLibraryResourceWithType:(LibraryResourceType) type fromIds:(NSArray<NSString*>*) ids;
@end

#pragma mark - Search the Library
#pragma mark - Fetch History
#pragma mark - Fetch Recent
#pragma mark - Fetch Library Recent


#pragma mark - Manage Library Resources (管理库资源(增删))
/**
 管理库资源
 */
@interface PersonalizedRequestFactory(ManagerLibrarySource)

/**
 操作类型
 - ManagerLibraryAddOperation:      增加
 - ManagerLibraryDeleteOperation:   删除
 */
typedef NS_ENUM(NSUInteger,ManagerLibraryOperation){
    ManagerLibraryAddOperation,
    ManagerLibraryDeleteOperation
};

/**
 管理库资源

 @param operation   操作(增加/删)
 @param type        资源类型
 @param identifier  资源标识
 @return            请求体
 */
-(NSURLRequest*) managerLibrarySourcesWithOperation:(ManagerLibraryOperation)operation resourceType:(LibraryResourceType) type andId:(NSString*) identifier;

@end



#pragma mark - 修改库播放列表
@interface PersonalizedRequestFactory(ModifyLibraryPlaylists)

/**
 修改播放列表操作
 - ModifyOperationCreateNewLibraryPlaylist:             创建新的播放列表
 - ModifyOperationReplaceLibraryPlaylistAttributes:     替换播放列表属性(名称/描叙)
 - ModifyOperationUpdateLibraryPlaylistAttributes:      更新播放列表属性
 - ModifyOperationAddTracksToLibraryPlaylist:           向播放例表添加Tracks
 - ModifyOperationReplaceTrackListForLibraryPlaylist:   替换播放列表Track
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
 - DeleteModeLast:  最后一个出现
 - DeleteModeAll:   全部
 */
typedef NS_ENUM(NSUInteger,DeleteMode) {
    DeleteModeFirst,
    DeleteModeLast,
    DeleteModeAll
};

/**
 删除的Track 类型

 - DeleteLibrarySongsType:          歌曲类型
 - DeleteLibraryMusicVideosType:    音乐视频类型
 */
typedef NS_ENUM(NSUInteger, DeleteTrackType){
    DeleteLibrarySongsType,
    DeleteLibraryMusicVideosType
};

/**
 修改列表 (删除 使用-deleteTracksFromLibraryPlaylistIdentifier: 方法)

 @param type                操作类型
 @param playlistIdnetifier  播放列表标识
 @param jsonPlayload        json数据
 @return                    请求体
 */
-(NSURLRequest *) modifyLibraryPlaylistsWithOperation:(ModifyOperationType) type
                                               fromId:(NSString*) playlistIdnetifier
                                       andJSONPayload:(NSDictionary*) jsonPlayload;

/**
 删除播放列表中的track

 @param identifier          列表identifier
 @param type                track类型
 @param deleteIdentifier    track 标识
 @param mode                删除模式
 @return                    请求体
 */
-(NSURLRequest*)deleteTracksFromLibraryPlaylistIdentifier:(NSString*)identifier
                                                    types:(DeleteTrackType)type
                                                      ids:(NSString*) deleteIdentifier
                                                     mode:(DeleteMode) mode;

@end



#pragma mark - 管理Rating
/**
 管理catalog 和 libraty rating
 */
@interface PersonalizedRequestFactory(ManagerRating)

/**
 Rating操作
 - RatingsGetOperation:     获取Rating
 - RatingsAddOperation:     增加Rating
 - RatingsDeleteOperation:  删除Rating
 */
typedef NS_ENUM(NSUInteger, RatingsOperation){
    RatingsGetOperation,
    RatingsAddOperation,
    RatingsDeleteOperation,
};

/**
 rating管理资源类型

 - ResourcesPersonalAlbumType:              个人专辑
 - ResourcesPersonalMusicVideosType:        个人音乐视频
 - ResourcesPersonalLibraryMusicVideosType: 个人库音乐视频
 - ResourcesPersonalPlaylistsType:          个人播放列表
 - ResourcesPersonalLibraryPlaylistsType:   个人库播放列表
 - ResourcesPersonalSongType:               个人歌曲
 - ResourcesPersonalLibrarySongType:        个人库歌曲
 - ResourcesPersonalStationType:            个人电台
 */
typedef NS_ENUM(NSUInteger, ResourcesType){
    ResourcesPersonalAlbumType,
    ResourcesPersonalMusicVideosType,
    ResourcesPersonalLibraryMusicVideosType,
    ResourcesPersonalPlaylistsType,
    ResourcesPersonalLibraryPlaylistsType,
    ResourcesPersonalSongType,
    ResourcesPersonalLibrarySongType,
    ResourcesPersonalStationType
};


/**
 管理Rating

 @param operation   操作类型
 @param type        资源类型
 @param ids         资源标识数组
 @return            请求体
 */
-(NSURLRequest*) managerCatalogAndLibraryRatingsWithOperatin:(RatingsOperation) operation
                                               resourcesType:(ResourcesType) type
                                                      andIds:(NSArray<NSString*>*) ids;
@end



#pragma mark - 获取推荐
/**
 获取推荐
 */
@interface PersonalizedRequestFactory(FetchRecommendations)

/**
 获取类型

 - FetchDefaultRecommendationsType:     默认推荐类型
 - FetchAlbumRecommendationsType:       专辑推荐类型
 - FetchPlaylistRecommendationsType:    播放列表类型
 - FetchAnRecommendatinsType:           获取单个推荐类型(此时要传入推荐identifier)
 - FetchMultipleRecommendationsType:    获取多个推荐类型(需要传入推荐identifier)
 */
typedef NS_ENUM(NSUInteger,FetchType){
    FetchDefaultRecommendationsType,
    FetchAlbumRecommendationsType,
    FetchPlaylistRecommendationsType,
    FetchAnRecommendatinsType,
    FetchMultipleRecommendationsType
};

/**
 创建推荐获取请求

 @param type    获取类型
 @param ids     资源标识(如果需要)
 @return        请求体
 */
-(NSURLRequest*) fetchRecommendationsWithType:(FetchType)type andIds:(NSArray<NSString*>*) ids;

@end





