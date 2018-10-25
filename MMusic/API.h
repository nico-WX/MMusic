//
//  API.h
//  MMusic
//
// 
//

#import <Foundation/Foundation.h>
#import "APIRoot.h"
#import "Library.h"

#pragma mark - 枚举
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
    ChartsMusicVideos,
    ChartsAll
};


@interface API : APIRoot

#pragma mark - 个人请求实例
/**获取库资源实例*/
@property(nonatomic, strong) Library *library;

#pragma mark - 实例方法
/**
 通过资源标识获取目录资源

 @param ids     资源标识
 @param catalog 资源类型
 @param handle  数据回调
 */
-(void)resources:(NSArray<NSString*>*)ids byType:(Catalog)catalog callBack:(RequestCallBack)handle;

/**
 获取与目录资源标识相关的资源(如某个艺人的专辑,单曲等), 注意:stations 没有周边资源

 @param identifier  目标id
 @param catalog     目标类型
 @param name        周边关系(如专辑的 artists,songs 等等)
 @param handle      数据回调
 */
-(void)relationship:(NSString*)identifier byType:(Catalog)catalog forName:(NSString*)name callBack:(RequestCallBack)handle;

/**
 通过ISRC(国际录音编码) 获取MV

 @param ISRCs   MV录音编码列表
 @param handle  数据回调
 */
-(void)musicVideosByISRC:(NSArray<NSString*>*)ISRCs callBack:(RequestCallBack)handle;

/**
 通过ISRC 获取Song

 @param ISRCs   song编码列表
 @param handle  数据回调
 */
-(void)songsByISRC:(NSArray<NSString*>*)ISRCs callBack:(RequestCallBack)handle;

/**
 当前地区的排行榜数据

 @param type    排行榜类型
 @param handle  数据回调
 */
-(void)chartsByType:(ChartsType)type callBack:(RequestCallBack)handle;


//Fetch Genres  未实现



/**
 搜索目录资源

 @param term    搜索字段
 @param handle  数据回调
 */
-(void)searchForTerm:(NSString*)term callBack:(RequestCallBack)handle;

/**
 搜索字段提示

 @param term    搜索提示关键字段
 @param handle  数据回调
 */
-(void)searchHintsForTerm:(NSString*)term callBack:(RequestCallBack)handle;


@end
