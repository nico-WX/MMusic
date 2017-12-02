//
//  PersonalizedRequestFactory.h
//  MMusic
//
//  Created by Magician on 2017/11/25.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark EnumType
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
typedef NS_OPTIONS(NSUInteger, ManageRatingsType){
    /**获取单张专辑评价*/
    ManagePersonalAlbumRatingType,
    /**获取多张专辑评价*/
    ManageMultiplePersonalAlbumRatingsType,
    /**增加专家评价*/
    ManageAddAlbumRatingsType,
    /**删除一张专辑的评价*/
    ManageDeleteAlbumRatingsType,
    /**获取一张MV评价*/
    ManagePersonalMusicVideoRatingsType,
    /**获取多张MV评价*/
    ManageMultiplePersonalMusicVideoRatingsType,
    /**增加一张MV评价*/
    ManageAddMusicVideoRatingsType,
    /**删除一张MV评价*/
    ManageDeleteMusicVideoRatingsType,
    /**获取一张播放列表评价*/
    ManagePersonalPlaylistRatingsType,
    /**获取多张播放列表评价*/
    ManageMultiplePlaylistRatingsType,
    /**增加一张播放列表评价*/
    ManageAddPlaylistRatingsType,
    /**删除播放列表评价*/
    ManageDeletePlaylistRatingsType,
    /**获取一首歌曲评价*/
    ManagePersonalSongRatingsType,
    /**获取多首歌曲评价*/
    ManageMultipleSongRatingsType,
    /**增加一首歌曲评价*/
    ManageAddSongRatingsType,
    /**删除一首歌曲评价*/
    ManageDeleteSongRatingsType,
    /**获取一个电台的评价*/
    ManagePersonalStationRatingsType,
    /**多个电台评价*/
    ManageMultipleStationRatingsType,
    /**增加一个电台评价*/
    ManageAddStationRatingsType,
    /**删除一个电台评价*/
    ManageDeleteStationRatingsType
};

/**个性化请求工厂*/
@interface PersonalizedRequestFactory : NSObject
/**根路径*/
@property(nonatomic,copy) NSString *rootPath;


#pragma mark instance method
/**创建个性化请求, 注意:(单张推荐和多张推荐需要在ids中提供Identifier,其他请求设置空数组)*/
-(NSURLRequest*) createRequestWithType:(PersonalizedType) type resourceIds:(NSArray<NSString*>*) ids;

/**评价管理请求(增加评价需要另外设置请求体 1为喜欢 -1为不喜欢) format:(
 {"type":"rating",
  "attributes":{
    "value":1 Or -1
  }
 })*/
-(NSURLRequest*) createManageRatingsRequestWithType:(ManageRatingsType) type resourceIds:(NSArray<NSString*> *) ids isLikes:(BOOL) likes;

/**设置请求评价他请求体*/
//-(NSURLRequest*) changeRatingRequestWithReuqest:(NSURLRequest*) request isLikes:(BOOL) likes;
@end
