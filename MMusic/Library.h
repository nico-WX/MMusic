//
//  Library.h
//  MMusic
//
//  Created by Magician on 2018/6/25.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APIRoot.h"

/**
 用户云库资源类型

 - CLibraryAlbums:      用户云音乐库专辑
 - CLibraryArtists:     用户云音乐库艺人
 - CLibraryMusicVideos: 用户云音乐库MV
 - CLibraryPlaylists:   用户云音乐库播放列表
 - CLibrarySongs:       用户云音乐库歌曲
 */
typedef NS_ENUM(NSUInteger, CLibrary){
    CLibraryAlbums,
    CLibraryArtists,
    CLibraryMusicVideos,
    CLibraryPlaylists,
    CLibrarySongs
};

/**
 搜索云音乐库资源类型

 - SLibrarySongs:       云音乐库歌曲
 - SLibraryAlbums:      云音乐库专辑
 - SLibraryArtists:     云音乐库艺人
 - SLibraryPlaylists:   云音乐库播放列表
 - SLibraryMusicVideos: 云音乐库MV
 */
typedef NS_ENUM(NSUInteger, SLibrary){
    SLibrarySongs,
    SLibraryAlbums,
    SLibraryArtists,
    SLibraryPlaylists,
    SLibraryMusicVideos
};

/**
 添加到音乐库中的资源类型

 - AddAlbums:       专辑
 - AddPlaylists:    歌单
 - AddMusicVideos:  MV
 - AddSongs:        歌曲
 */
typedef NS_ENUM(NSUInteger, AddType){
    AddAlbums,
    AddPlaylists,
    AddMusicVideos,
    AddSongs
};

/**
 管理个人CatalogRating 资源类型

 - CRatingAlbums:       专辑
 - CRatingMusicVideos:  MV
 - CRatingPlaylists:    播放列表
 - CRatingSongs:        歌曲
 - CRatingStations:     电台
 */
typedef NS_ENUM(NSUInteger, CRating){
    CRatingAlbums,
    CRatingMusicVideos,
    CRatingPlaylists,
    CRatingSongs,
    CRatingStations
};


@interface Library : APIRoot

/**
 通过标识获取个人资料库资源, 空的资源标识默认获取全部资源

 @param ids     资源标识列表
 @param library 库资源类型
 @param handle  数据回调
 */
-(void)resource:(NSArray<NSString*>*)ids byType:(CLibrary)library callBack:(CallBack)handle;

/**
 获取资源周边相关的资源

 @param identifier  目标资源id
 @param library     目标资源类型
 @param name        周边相关名称(如songs 的artistis 等)
 @param handle      数据回调
 */
-(void)relationship:(NSString*)identifier forType:(CLibrary)library byName:(NSString*)name callBacl:(CallBack) handle;

/**
 搜索云音乐库

 @param term    搜索字段
 @param library 搜索音乐库资源类型
 @param handle  数据回调
 */
-(void)searchForTerm:(NSString*)term byType:(SLibrary)library callBack:(CallBack)handle;

/**
 获取重复播放高的内容

 @param handle 数据回调
 */
-(void)heavyRotationContentInCallBack:(CallBack)handle;

/**
 最近播放的资源

 @param handle 数据回调
 */
-(void)recentlyPlayedInCallBack:(CallBack)handle;

/**
 最近播放的无线电台

 @param handle 数据回调
 */
-(void)recentStationsInCallBack:(CallBack)handle;

/**
 最近添加到音乐库的资源

 @param handle 数据回调
 */
-(void)recentlyAddedToLibraryInCallBack:(CallBack)handle;

/**
 添加指定的资源到音乐库

 @param ids 资源Ids
 @param type 资源类型
 @param handle 处理结果
 */
-(void)addResourceToLibraryForIdentifiers:(NSArray<NSString*>*)ids byType:(AddType) type callBack:(CallBack)handle;

/**
 创建新的音乐库播放列表

 @param json 请求体字典
 */
-(void)createNewLibraryPlaylistsForJsonPlayload:(NSDictionary*)json callBack:(CallBack)handle;


/**
 添加歌曲到个人播放列表

 @param identifier  个人播放列表id
 @param tracks      song 播放参数字典列表
 @param handle      处理结果
 */
-(void)addTracksToLibraryPlaylists:(NSString *)identifier tracks:(NSArray<NSDictionary*>*)tracks callBack:(CallBack)handle;

/**
 获取目录Rating

 @param ids  id数组
 @param type 资源类型
 @param handle 数据回调
 */
-(void)getRating:(NSArray<NSString*>*)ids byType:(CRating)type callBack:(CallBack)handle;

/**
 添加目录Rating

 @param identifier 目录资源id
 @param type 资源类型
 @param value 传入 1或者-1
 @param handle 数据回调
 */
-(void)addRating:(NSString*)identifier byType:(CRating)type value:(int)value callBack:(CallBack)handle;


/**
 删除Rating

 @param identifier 要删除的资源id
 @param type 资源类型
 @param handle 处理结果
 */
-(void)deleteRating:(NSString*)identifier byType:(CRating)type callBack:(CallBack)handle;

/**
 获取默认推荐

 @param handle 数据回调
 */
-(void)defaultRecommendationsInCallBack:(CallBack)handle;

@end
