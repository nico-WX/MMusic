//
//  API.h
//  MMusic
//

#import <Foundation/Foundation.h>
#import "APIRoot.h"
#import "Library.h"

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


@interface API : APIRoot

#pragma mark - 用户资源入口
/**个人资源*/
@property(nonatomic, strong) Library *library;

#pragma mark - 公开资源实例方法
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


/**
 搜索目录资源

 @param term    搜索字段
 @param handle  数据回调
 */
- (void)searchForTerm:(NSString*)term callBack:(RequestCallBack)handle;

/**
 搜索字段提示

 @param term    搜索提示关键字段
 @param handle  数据回调
 */
- (void)searchHintsForTerm:(NSString*)term callBack:(RequestCallBack)handle;
@end
