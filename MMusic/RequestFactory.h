//
//  RequestFactory.h
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 普通请求工厂
 */
@interface RequestFactory : NSObject
/**根路径*/
@property(nonatomic, copy) NSString *rootPath;
/**当前用户地区商店代码*/
@property(nonatomic, copy) NSString *storefront;

/**
 通过子路径创建请求体
 @param href 子路径
 @return 请求体
 */
- (NSURLRequest*)createRequestWithHref:(NSString*) href;

 @end


//不用个人令牌
//#pragma mark - Get Started
//#pragma mark - Fetch Storefront
//#pragma mark - Fetch Catalog Albums, Music Videos, Playlists, Songs, and Stations
//#pragma mark - Fetch Catalog Artists, Curators, Activities, and Apple Curators
//#pragma mark - Fetch Charts
//#pragma mark - Fetch Genres
//#pragma mark - Search the Catalog

//按 API分类
#pragma mark - Get Started  (开启)
#pragma mark - Fetch Storefront (获取地区商店)
#pragma mark - Fetch Catalog Albums, MusicVideos, Playlists, Songs,Stations ,Artists, Curators, Activities,Apple Curators (通过ID获取资源)

/**
 通过资源id 获取资源
 */
@interface RequestFactory(FetchResource)
/**
 获取资源类型

 - ResourceAlbumsType:          专辑
 - ResourceMusicVideosType:     音乐视频
 - ResourcePlaylistsType:       播放列表
 - ResourceSongsType:           歌曲
 - ResourceStationsType:        电台
 - ResourceArtistsType:         艺人
 - ResourceCuratorsType:        出版商 ?
 - ResourceActivitiesType:      活动
 - ResourceAppleCuratorsType:   apple出版?
 */
typedef NS_ENUM(NSUInteger,ResourceType){
    ResourceAlbumsType,
    ResourceMusicVideosType,
    ResourcePlaylistsType,
    ResourceSongsType,
    ResourceStationsType,
    ResourceArtistsType,
    ResourceCuratorsType,
    ResourceActivitiesType,
    ResourceAppleCuratorsType
};

/**
 创建获取资源请求体

 @param type 获取资源类型
 @param ids 资源id 列表
 @return 请求体
 */
-(NSURLRequest *) fetchResourceFromType:(ResourceType) type andIds:(NSArray<NSString*>*) ids;
@end



#pragma mark - Fetch Charts (获取排行榜)

/**
 获取地区排行榜
 */
@interface RequestFactory(FetchCharts)

/**
 排行榜类型
 
 - ChartsSongsType:         歌曲排行榜
 - ChartsAlbumsType:        专辑排行榜
 - ChartsMusicVideosType:   音乐视频排行榜
 - ChartsPlaylistsType:     播放列表排行榜
 */
typedef NS_ENUM(NSUInteger, ChartsType){
    ChartsSongsType,
    ChartsAlbumsType,
    ChartsMusicVideosType,
    ChartsPlaylistsType,
};
-(NSURLRequest*) fetchChartsFromType:(ChartsType) type;
@end
#pragma mark - Fetch Genres (获取派系)


#pragma mark - Search the Catalog   (搜索)

/**
 搜索目录
 */
@interface RequestFactory(SearchCatalog)

/**
搜索类型

 - SearchDefaultsType: 默认搜索所有
 - SearchAlbumsType: 搜索专辑
 - SearchPlaylistsType: 搜索播放列表
 - SearchSongsType: 搜索歌曲
 - SearchMusicVideosType: 搜索MV
 - SearchStationsType: 搜索电台
 - SearchCuratorsType: 搜索出版商
 - SearchAppleCuratorsType: 搜索apple出版
 - SearchArtisrsType: 搜索艺人
 - SearchActivitiesType: 搜索活动
 */
typedef NS_OPTIONS(NSUInteger, SearchType){
    SearchDefaultsType =    0,
    SearchAlbumsType =      1 << 0,
    SearchPlaylistsType =   1 << 1,
    SearchSongsType =       1 << 2,
    SearchMusicVideosType=  1 << 3,
    SearchStationsType=     1 << 4,
    SearchCuratorsType=     1 << 5,
    SearchAppleCuratorsType=1 << 6,
    SearchArtisrsType=      1 << 7,
    SearchActivitiesType=   1 << 8,
};


/**
 创建文本搜索

 @param text 文本
 @return 请求体
 */
-(NSURLRequest*)createSearchWithText:(NSString*) text;

/**
 搜索指定的资源类型

 @param text 搜索文本
 @param type 搜索类型
 @return 请求体
 */
-(NSURLRequest*)searchCatalogResourcesForText:(NSString*)text forType:(SearchType) type;


/**
 创建搜索提示

 @param text 提示字符串
 @return 请求体
 */
-(NSURLRequest*)fetchSearchHintsForTerms:(NSString*) text;
@end




