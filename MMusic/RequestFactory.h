//
//  RequestFactory.h
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>

/**请求类型*/
typedef NS_OPTIONS(NSUInteger, RequestType){
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

/**排行榜类型*/
typedef NS_OPTIONS(NSUInteger, ChartType){
    /**歌曲排行榜*/
    ChartSongsType,
    /**专辑排行榜*/
    ChartAlbumsType,
    /**音乐视频排行榜*/
    ChartMusicVideosType
};


/**普通请求工厂类*/
@interface RequestFactory : NSObject
/**根路径*/
@property(nonatomic, copy) NSString *rootPath;
/**当前用户商店代码*/
@property(nonatomic, copy) NSString *storefront;

/**(一般请求)请求*/
-(NSURLRequest*) createRequestWithType:(RequestType)type resourceIds:(NSArray<NSString*>*) ids;
/**排行榜请求*/
-(NSURLRequest*) createChartWithChartType:(ChartType) type;
/**搜索请求*/
-(NSURLRequest*) createSearchWithText:(NSString*) searchText;
/**通过文本获取搜索历史*/
-(NSURLRequest*) createSearchHintsWithTerm:(NSString*) term;

 @end
