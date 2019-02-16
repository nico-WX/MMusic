//
//  Catalog.h
//  MMusic
//

#import <Foundation/Foundation.h>
#import "APIRoot.h"
#import "Library.h"

@class Resource;
#pragma mark - 枚举
/**
 公共目录资源类型
 */
typedef NS_ENUM(NSUInteger, ResourceType){
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
 地区排行榜类型
 */
typedef NS_ENUM(NSUInteger, ChartsType){
    ChartsAlbums,
    ChartsPlaylists,
    ChartsSongs,
    ChartsMusicVideos,
    ChartsAll
};


@interface Catalog : APIRoot
@property(nonatomic, readonly) NSString *catalogPath;

#pragma mark - 公开资源实例方法


/**
 获取歌单,播放列表等 曲目

 @param resource 专辑等包含曲目的资源
 @param handle JSON 数据回调及响应头
 */
- (void)songListWithResource:(Resource*)resource completion:(RequestCallBack)handle;


/**
 通过资源标识获取目录资源

 @param ids     资源标识
 @param catalog 资源类型
 @param handle  数据回调
 */
- (void)resources:(NSArray<NSString*>*)ids byType:(ResourceType)catalog callBack:(RequestCallBack)handle;

/**
 获取与Identifier资源标识 有关系的资源(如某个艺人的专辑,单曲等), 注意:stations 没有周边资源

 @param identifier  目标id
 @param catalog     目标类型
 @param name        周边关系(如专辑的 artists,songs 等等)
 @param handle      数据回调
 */
- (void)relationship:(NSString*)identifier byType:(ResourceType)catalog forName:(NSString*)name callBack:(RequestCallBack)handle;

/**
 通过ISRC(国际录音编码) 获取MV

 @param ISRCs   MV录音编码列表
 @param handle  数据回调
 */
- (void)musicVideosByISRC:(NSArray<NSString*>*)ISRCs callBack:(RequestCallBack)handle;

/**
 通过ISRC 获取Song

 @param ISRCs   song编码列表
 @param handle  数据回调
 */
- (void)songsByISRC:(NSArray<NSString*>*)ISRCs callBack:(RequestCallBack)handle;

/**
 当前地区的排行榜数据

 @param type    排行榜类型
 @param handle  数据回调
 */
- (void)chartsByType:(ChartsType)type callBack:(RequestCallBack)handle;

//Fetch Genres  未实现



@end
