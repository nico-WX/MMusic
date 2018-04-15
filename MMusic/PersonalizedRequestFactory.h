//
//  PersonalizedRequestFactory.h
//  MMusic
//
//  Created by Magician on 2017/11/25.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>

/**个性化请求类型*/
typedef NS_OPTIONS(NSUInteger, PersonalizedType){
    /**高度重复播放*/
    PersonalizedRotationContentType,
    /**最近播放资源*/
    PersonalizedRecentlyPlayedType,
    /**最近播放电台*/
    PersonalizedRecentStationsType,
    /**默认推荐*/
    PersonalizedDefaultRecommendationsType,
    /**推荐专辑*/
    PersonalizedAlbumRecommendationsType,
    /**推荐播放列表*/
    PersonalizedPlaylistRecommendationsType,
    /**单张推荐*/
    PersonalizedRecommendationType,
    /**多张推荐*/
    PersonalizedMultipleRecommendationType,
};

/**管理评价请求类型*/
typedef NS_OPTIONS(NSUInteger, RatingsType){
    /**获取单张专辑评价*/
    GetAlbumRatingType,
    /**获取多张专辑评价*/
    GetMultipleAlbumRatingsType,
    /**增加专家评价*/
    AddAlbumRatingsType,
    /**删除一张专辑的评价*/
    DeleteAlbumRatingsType,

    /**获取一张MV评价*/
    GetMusicVideoRatingsType,
    /**获取多张MV评价*/
    GetMultipleMusicVideoRatingsType,
    /**增加一张MV评价*/
    AddMusicVideoRatingsType,
    /**删除一张MV评价*/
    DeleteMusicVideoRatingsType,

    /**获取一张播放列表评价*/
    GetPlaylistRatingsType,
    /**获取多张播放列表评价*/
    GetMultiplePlaylistRatingsType,
    /**增加一张播放列表评价*/
    AddPlaylistRatingsType,
    /**删除播放列表评价*/
    DeletePlaylistRatingsType,

    /**获取一首歌曲评价*/
    GetSongRatingsType,
    /**获取多首歌曲评价*/
    GetMultipleSongRatingsType,
    /**增加一首歌曲评价*/
    AddSongRatingsType,
    /**删除一首歌曲评价*/
    DeleteSongRatingsType,

    /**获取一个电台的评价*/
    GetStationRatingsType,
    /**多个电台评价*/
    GetMultipleStationRatingsType,
    /**增加一个电台评价*/
    AddStationRatingsType,
    /**删除一个电台评价*/
    DeleteStationRatingsType,
};

/**个性化请求工厂*/
@interface PersonalizedRequestFactory : NSObject
/**根路径*/
@property(nonatomic,copy) NSString *rootPath;

//便捷方法
+(instancetype) personalizedRequestFactory;

#pragma mark instance method
/**创建个性化请求, 注意:(单张推荐和多张推荐需要在ids中提供Identifier,其他请求设置空数组)*/
-(NSURLRequest*) createRequestWithType:(PersonalizedType) type resourceIds:(NSArray<NSString*>*) ids;

/**评价管理请求(增加评价需要另外设置请求体 (yes)1为喜欢 (no)-1为不喜欢)*/
-(NSURLRequest*) createManageRatingsRequestWithType:(RatingsType) type resourceIds:(NSArray<NSString*> *) ids;


@end
