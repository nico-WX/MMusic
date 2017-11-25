//
//  PersonalizedRequestFactory.h
//  MMusic
//
//  Created by Magician on 2017/11/25.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>

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
/**个性化请求工厂*/
@interface PersonalizedRequestFactory : NSObject
@property(nonatomic,strong) NSString *rootPath;

/**创建个性化请求, 注意:(单张推荐和多张推荐需要在ids中提供Identifier,其他请求设置空数组)*/
-(NSURLRequest*) createRequestWithType:(PersonalizedType) type resourceIds:(NSArray<NSString*>*) ids;
@end
