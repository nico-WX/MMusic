//
//  PersonalizedRequestFactory.m
//  MMusic
//
//  Created by Magician on 2017/11/25.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "PersonalizedRequestFactory.h"
#import "NSObject+Tool.h"

@implementation PersonalizedRequestFactory

-(instancetype)init{
    if (self = [super init]) {
        _rootPath = @"https://api.music.apple.com";
        _rootPath = [_rootPath stringByAppendingPathComponent:@"v1"];
        _rootPath = [_rootPath stringByAppendingPathComponent:@"me"];
    }
    return self;
}

#pragma mark - 映射不同的请求类型到 具体路径
/**解析字符串数组参数 并拼接返回*/
-(NSString *) resolveStringArrayWithArray:(NSArray<NSString*> *) ids{
    NSString *string = [NSString string];
    if (ids.count == 1) {
        string = ids.lastObject;
    }else{
        for (NSString *str in ids ) {
            string = [string stringByAppendingFormat:@"%@,",str];
        }
    }
    return string;
}
/**解析个性化请求类型*/
-(NSString *) resolveRequestType:(PersonalizedType) type{
    NSString *string ;
    switch (type) {
        case PersonalizedRotationContentType:
            string = @"history/heavy-rotation";
            break;
        case PersonalizedRecentlyPlayedType:
            string = @"recent/played";
            break;
        case PersonalizedRecentStationsType:
            string = @"recent/radio-stations";
            break;
        case PersonalizedDefaultRecommendationsType:
        case PersonalizedRecommendationType:
            string = @"recommendations";
            break;
        case PersonalizedAlbumRecommendationsType:
            string = @"recommendations?type=albums";
            break;
        case PersonalizedPlaylistRecommendationsType:
            string = @"recommendations?type=playlists";
            break;
        case PersonalizedMultipleRecommendationType:
            string = @"recommendations?ids=";
            break;
    }
    return string;
}

/**解析评价管理请求类型*/
-(NSString*) resolveRatingManagerRequestType:(RatingsType) type{
    NSString *string ;
    switch (type) {
        //管理专辑评价
        case GetAlbumRatingType:
        case AddAlbumRatingsType:
        case DeleteAlbumRatingsType:
            string = @"albums";
            break;
        case GetMultipleAlbumRatingsType:
            string = @"albums?ids=";
            break;

        //管理MV评价
        case GetMusicVideoRatingsType:
        case AddMusicVideoRatingsType:
        case DeleteMusicVideoRatingsType:
            string = @"music-videos";
            break;
        case GetMultipleMusicVideoRatingsType:
            string = @"music-videos?ids=";
            break;

        //管理播放列表评价
        case GetPlaylistRatingsType:
        case AddPlaylistRatingsType:
        case DeletePlaylistRatingsType:
            string = @"playlists";
            break;
        case GetMultiplePlaylistRatingsType:
            string = @"playlists?ids=";
            break;

        //管理歌曲评价
        case GetSongRatingsType:
        case AddSongRatingsType:
        case DeleteSongRatingsType:
            string = @"songs";
            break;
        case GetMultipleSongRatingsType:
            string = @"songs?ids=";
            break;

        //管理电台评价
        case GetStationRatingsType:
        case AddStationRatingsType:
        case DeleteStationRatingsType:
            string = @"stations";
            break;
        case GetMultipleStationRatingsType:
            string = @"stations?ids=";
            break;
    }
    return string;
}

#pragma mark - 创建请求对象
-(NSURLRequest *)createRequestWithType:(PersonalizedType)type resourceIds:(NSArray<NSString *> *)ids{
    NSString *requestType = @"";
    if (ids != NULL) {
         requestType = [self resolveRequestType:type];
    }
    NSString *path = [self.rootPath stringByAppendingPathComponent:requestType];

    //这两个请求类型需要使用资源identifier 对应不同的拼接方式
    NSString *identifier = [self resolveStringArrayWithArray:ids];
    if (type == PersonalizedRecommendationType) {
        path = [path stringByAppendingPathComponent:identifier];
    }else if(type == PersonalizedMultipleRecommendationType){
        path = [path stringByAppendingString:identifier];
    }
    return  [self createRequestWithURLString:path setupUserToken:YES];
}

-(NSURLRequest*) createManageRatingsRequestWithType:(RatingsType) type resourceIds:(NSArray<NSString*> *) ids{
    NSString *path = [self.rootPath stringByAppendingPathComponent:@"ratings"];
    NSString *requestType = @"";
    if (ids != NULL) {
        requestType = [self resolveRatingManagerRequestType:type];
    }
    path = [path stringByAppendingPathComponent:requestType];

    //区分参数拼接方式
    NSString *identifier = [self resolveStringArrayWithArray:ids];
    if (ids.count == 1) {
        path = [path stringByAppendingPathComponent:identifier];
    }else{
        path = [path stringByAppendingString:identifier];
    }
    NSMutableURLRequest *request = (NSMutableURLRequest*)[self createRequestWithURLString:path setupUserToken:YES];

    //设置请求方法  和请求体
    switch (type) {

        //删除评级
        case DeleteMusicVideoRatingsType:
        case DeleteAlbumRatingsType:
        case DeleteStationRatingsType:
        case DeletePlaylistRatingsType:
        case DeleteSongRatingsType:
            [request setHTTPMethod:@"DELETE"];
            break;

        //增加评级
        case AddStationRatingsType:
        case AddSongRatingsType:
        case AddAlbumRatingsType:
        case AddPlaylistRatingsType:
        case AddMusicVideoRatingsType:{
            [request setHTTPMethod:@"PUT"];
            NSDictionary *dict = @{@"type":@"rating",@"attributes":@{@"value":@1}};
            NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingSortedKeys error:nil];
            [request setHTTPBody:data];
            break;
        }
        //其他默认
        default:
            break;
    }
    return request;
}
@end
