//
//  Library.h
//  MMusic
//
//  Created by Magician on 2018/6/25.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>



/**
 resources from a user's Cloud Library

 - CLibraryAlbums:  用户云音乐库专辑
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
 搜索云音乐库类型

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


@interface Library : NSObject

/**
 通用获取用户云音乐库资源方法, 传空ids获取所有库资源

 @param ids     库资源id
 @param library 库资源类型
 @param handle  数据回调
 */
-(void)resource:(NSArray<NSString*>*)ids byType:(CLibrary)library callBack:(void(^)(NSDictionary*json)) handle;

/**
 获取资源周边相关的资源

 @param identifier  目标资源id
 @param library     目标资源类型
 @param name        周边相关名称(如songs 的artistis 等)
 @param handle      数据回调
 */
-(void)relationship:(NSString*)identifier forType:(CLibrary)library byName:(NSString*)name callBacl:(void(^)(NSDictionary*json)) handle;

/**
 搜索云音乐库

 @param term    搜索字段
 @param library 搜索音乐库资源类型
 @param handle  数据回调
 */
-(void)searchForTerm:(NSString*)term byType:(SLibrary)library callBack:(void(^)(NSDictionary*json))handle;

/**
 获取重复播放高的内容

 @param handle 数据回调
 */
-(void)heavyRotationContentInCallBack:(void(^)(NSDictionary*json))handle;

/**
 最近播放的资源

 @param handle 数据回调
 */
-(void)recentlyPlayedInCallBack:(void(^)(NSDictionary*json))handle;

/**
 最近播放的无线电台

 @param handle 数据回调
 */
-(void)recentStationsInCallBack:(void(^)(NSDictionary*json))handle;

/**
 最近添加到音乐库的资源

 @param handle 数据回调
 */
-(void)recentlyAddedToLibraryInCallBack:(void(^)(NSDictionary*json))handle;

/**
 添加指定的资源到音乐库

 @param ids 资源Ids
 @param type 资源类型
 */
-(void)addResourceToLibraryForIdentifiers:(NSArray<NSString*>*)ids byType:(AddType) type;


/**
 创建新的音乐库播放列表

 @param json 请求体字典
 */
-(void)createNewLibraryPlaylistsForJsonPlayload:(NSDictionary*)json callBack:(void(^)(NSDictionary*json))handle;


/**
 添加歌曲到个人播放列表

 @param identifier 播放列表ID
 @param json 歌曲json
 */
-(void)addTracksToLibraryPlaylistForIdentifier:(NSString*)identifier playload:(NSDictionary*)json;

@end
