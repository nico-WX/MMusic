//
//  RequestFactory.h
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 请求目录资源类型
 */
typedef NS_ENUM(NSUInteger, RequestType){
    /**单张专辑*/
    RequestAlbumType ,
    /**多张专辑*/
    RequestMultipleAlbumType,
    /**一张MV*/
    RequestMusicVideoType,
    /**多张MV*/
    RequestMultipleMusicVideoType,
    /**单张播放列表*/
    RequestPlaylistType,
    /**多张播放列表*/
    RequestMultiplePlaylistType,
    /**单首歌曲*/
    RequestSongType,
    /**多首歌曲*/
    RequestMultipleSongType,
    /**单个电台*/
    RequestStationType,
    /**多个电台*/
    RequestMultipleStationType,
    /**单个艺人*/
    RequestArtistType,
    /**多个艺人*/
    RequestMultipleArtistType,
    /**单个馆*/
    RequestCuratorType,
    /**多馆*/
    RequestMultipleCuratorType,
    /**单个活动*/
    RequestActivityType,
    /**多个活动*/
    RequestMultipleActivityType,
    /**单个Apple管理*/
    RequestAppleCuratorType,
    /**多个Apple管理*/
    RequestMultipleAppleCuratorType,
    /**热门流派*/
    RequestTopGenresType,
    /**单个流派*/
    RequestGenresType,
    /**多个流派*/
    RequestMultipleGenresType

};

/**
 排行榜请求类型
 */
typedef NS_ENUM(NSUInteger, ChartsType){
    /**歌曲排行榜*/
    ChartsSongsType,
    /**专辑排行榜*/
    ChartsAlbumsType,
    /**音乐视频排行榜*/
    ChartsMusicVideosType,
    /**歌曲列表*/
    ChartsPlaylistsType
};


/**
 普通请求工厂
 */
@interface RequestFactory : NSObject
/**根路径*/
@property(nonatomic, copy) NSString *rootPath;
/**当前用户地区商店代码*/
@property(nonatomic, copy) NSString *storefront;

/**
 创建一般请求对象
 @param type 请求类型
 @param ids identifier字符串 数组
 @return 请求对象
 */
-(NSURLRequest*) createRequestWithType:(RequestType)type resourceIds:(NSArray<NSString*>*) ids;

/**
 创建排行榜请求对象
 @param type 排行榜类型
 @return 请求对象
 */
-(NSURLRequest*) createChartWithChartType:(ChartsType) type;

/**
 创建搜索请求对象
 @param searchText 搜索的文本
 @return 请求对象
 */
-(NSURLRequest*) createSearchWithText:(NSString*) searchText;

/**
 创建搜索提示请求对象
 @param term 提示相关的文本
 @return 请求对象
 */
-(NSURLRequest*) createSearchHintsWithTerm:(NSString*) term;

/**
 通过子路径创建请求体
 @param herf 子路径
 @return 请求体
 */
- (NSURLRequest*)createRequestWithHerf:(NSString*) herf;

 @end
