//
//  API.h
//  MMusic
//
//  Created by Magician on 2018/6/25.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Library.h"


/**
 目录资源类型

 - CatalogAlbums:       目录专辑
 - CatalogMusicVideos:  目录MV
 - CatalogPlaylists:    目录播放列表
 - CatalogSongs:        目录歌曲
 - CatalogStations:     目录电台
 - CatalogArtists:      目录艺人
 - CatalogCurators:     目录策划
 - CatalogActivities:   目录活动
 - CatalogAppleCurators:apple策划
 */
typedef NS_ENUM(NSUInteger, Catalog){
    CatalogAlbums,
    CatalogMusicVideos,
    CatalogPlaylists,
    CatalogSongs,
    CatalogStations,
    CatalogArtists,
    CatalogCurators,
    CatalogActivities,
    CatalogAppleCurators
};


/**
 排行榜

 - ChartsAlbums:        专辑排行榜
 - ChartsPlaylists:     播放列表排行榜
 - ChartsSongs:         歌曲排行榜
 - ChartsMusicVideos:   MV排行榜
 */
typedef NS_ENUM(NSUInteger, ChartsType){
    ChartsAlbums,
    ChartsPlaylists,
    ChartsSongs,
    ChartsMusicVideos
};


@interface API : NSObject
/**获取库资源实例*/
@property(nonatomic, strong) Library *library;

/**
 通用获取资源方法

 @param ids 资源id
 @param catalog 资源类型
 @param handle 数据回调
 */
-(void)resources:(NSArray<NSString*>*)ids byType:(Catalog)catalog callBack:(void(^)(NSDictionary* json)) handle;

/**
 通用获取与id资源有关系的周边资源, 注意:stations 没有周边资源

 @param identifier  目标id
 @param catalog     目标类型
 @param name        周边关系(artists,songs 等等)
 @param handle      数据回调
 */
-(void)relationship:(NSString*)identifier byType:(Catalog)catalog forName:(NSString*)name callBack:(void(^)(NSDictionary*json))handle;

/**
 通过ISRC 获取MV

 @param ISRCs MV编码数组
 @param handle 数据回调
 */
-(void)musicVideosByISRC:(NSArray<NSString*>*)ISRCs callBack:(void(^)(NSDictionary* json))handle;

/**
 通过ISRC 获取Song

 @param ISRCs song编码数组
 @param handle 数据回调
 */
-(void)songsByISRC:(NSArray<NSString*>*)ISRCs callBack:(void(^)(NSDictionary* json))handle;

/**
 排行榜数据

 @param type 排行榜类型
 @param handle 数据回调
 */
-(void)chartsByType:(ChartsType)type callBack:(void(^)(NSDictionary*json))handle;


//Fetch Genres  未实现


/**
 搜索目录资源

 @param term 搜索字段
 @param handle 数据回调
 */
-(void)searchForTerm:(NSString*)term callBack:(void(^)(NSDictionary*json))handle;


/**
 搜索字段提示

 @param term 搜索字段
 @param handle 数据回调
 */
-(void)searchHintsForTerm:(NSString*)term callBack:(void(^)(NSDictionary*json))handle;


@end
