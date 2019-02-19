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
 */
typedef NS_ENUM(NSUInteger, LibraryResourceType){
    CLibraryAlbums,         //用户云音乐库专辑
    CLibraryArtists,        //用户云音乐库艺人
    CLibraryMusicVideos,    //用户云音乐库MV
    CLibraryPlaylists,      //用户云音乐库播放列表
    CLibrarySongs           //用户云音乐库歌曲
};

/**
 搜索云音乐库资源类型
 */
typedef NS_ENUM(NSUInteger, SearchLibraryType){
    SLibrarySongs,      //云音乐库歌曲
    SLibraryAlbums,     //云音乐库专辑
    SLibraryArtists,    //云音乐库艺人
    SLibraryPlaylists,  //云音乐库播放列表
    SLibraryMusicVideos //云音乐库MV
};

/**
 添加到音乐库中的资源类型
 */
typedef NS_ENUM(NSUInteger, AddType){
    AddAlbums,      //专辑
    AddPlaylists,   //播放列表
    AddMusicVideos, //MV
    AddSongs        //单曲
};


@interface Library : APIRoot
@property(nonatomic, readonly)NSString *libraryPath;

/**
 通过标识获取个人资料库资源, 空的资源标识默认获取全部资源

 @param ids     资源标识列表
 @param library 库资源类型
 @param handle  数据回调
 */
- (void)resource:(NSArray<NSString*>*)ids byType:(LibraryResourceType)library callBack:(RequestCallBack)handle;

/**
 获取资源周边相关的资源

 @param identifier  目标资源id
 @param library     目标资源类型
 @param name        周边相关名称(如songs 的artistis 等)
 @param handle      数据回调
 */
- (void)relationship:(NSString*)identifier forType:(LibraryResourceType)library byName:(NSString*)name callBacl:(RequestCallBack)handle;

/**
 搜索云音乐库

 @param term    搜索字段
 @param library 搜索音乐库资源类型
 @param handle  数据回调
 */
- (void)searchForTerm:(NSString*)term byType:(SearchLibraryType)library callBack:(RequestCallBack)handle;


/**
 获取默认推荐

 @param handle 数据回调
 */
- (void)defaultRecommendationsInCallBack:(RequestCallBack)handle;


@end
