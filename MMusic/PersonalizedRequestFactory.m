//
//  PersonalizedRequestFactory.m
//  MMusic
//
//  Created by Magician on 2017/11/25.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "PersonalizedRequestFactory.h"
#import "AuthorizationManager.h"

@implementation PersonalizedRequestFactory
-(instancetype)init{
    if (self = [super init]) {
        _rootPath = @"https://api.music.apple.com";
        _rootPath = [_rootPath stringByAppendingPathComponent:@"v1"];
        _rootPath = [_rootPath stringByAppendingPathComponent:@"me"];
    }
    return self;
}

#pragma mark Tool
/**设置请求头*/
-(void)setupAuthorizationWithRequest:(NSMutableURLRequest *)request setupMusicUserToken:(BOOL)needSetupUserToken{

    //设置开发者Token 请求头
    NSString *developerToken = [AuthorizationManager shareAuthorizationManager].developerToken;
    if (developerToken) {
        developerToken = [NSString stringWithFormat:@"Bearer %@",developerToken];
        [request setValue:developerToken forHTTPHeaderField:@"Authorization"];
    }

    //个性化请求 设置UserToken 请求头
    if (needSetupUserToken == YES) {
        NSString *userToken = [AuthorizationManager shareAuthorizationManager].userToken;
        if (userToken){ [request setValue:userToken forHTTPHeaderField:@"Music-User-Token"];}
    }
}

/**通过urlString 生成请求体 并设置请求头*/
-(NSURLRequest*) createRequestWithURLString:(NSString*) urlString setupUserToken:(BOOL) setupUserToken{
    //转换URL中文及空格
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    //设置请求头
    [self setupAuthorizationWithRequest:request setupMusicUserToken:setupUserToken];
    return request;
}

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

        default:
            break;
    }
    return string;
}

/**解析评价管理请求类型*/
-(NSString*) resolveRatingManagerRequestType:(ManageRatingsType) type{
    NSString *string ;
    switch (type) {
        //管理专辑评价
        case ManagePersonalAlbumRatingType:
        case ManageAddAlbumRatingsType:
        case ManageDeleteAlbumRatingsType:
            string = @"albums";
            break;
        case ManageMultiplePersonalAlbumRatingsType:
            string = @"albums?ids=";
            break;
        //管理MV评价
        case ManagePersonalMusicVideoRatingsType:
        case ManageAddMusicVideoRatingsType:
        case ManageDeleteMusicVideoRatingsType:
            string = @"music-videos";
            break;
        case ManageMultiplePersonalMusicVideoRatingsType:
            string = @"music-videos?ids=";
            break;
        //管理播放列表评价
        case ManagePersonalPlaylistRatingsType:
        case ManageAddPlaylistRatingsType:
        case ManageDeletePlaylistRatingsType:
            string = @"playlists";
            break;
        case ManageMultiplePlaylistRatingsType:
            string = @"playlists?ids=";
            break;
        //管理歌曲评价
        case ManagePersonalSongRatingsType:
        case ManageAddSongRatingsType:
        case ManageDeleteSongRatingsType:
            string = @"songs";
            break;
        case ManageMultipleSongRatingsType:
            string = @"songs?ids=";
            break;
        //管理电台评价
        case ManagePersonalStationRatingsType:
        case ManageAddStationRatingsType:
        case ManageDeleteStationRatingsType:
            string = @"stations";
            break;
        case ManageMultipleStationRatingsType:
            string = @"stations?ids=";
            break;
        default:
            break;
    }
    return string;
}

#pragma mark implementation create request
-(NSURLRequest *)createRequestWithType:(PersonalizedType)type resourceIds:(NSArray<NSString *> *)ids{
    NSString *requestType = [self resolveRequestType:type];
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

-(NSURLRequest *)createManageRatingsRequestWithType:(ManageRatingsType)type resourceIds:(NSArray<NSString *> *)ids isLikes:(BOOL)likes{
    NSString *requestType = [self resolveRatingManagerRequestType:type];
    NSString *path = [self.rootPath stringByAppendingPathComponent:@"ratings"];
    path = [path stringByAppendingPathComponent:requestType];

    //区分参数拼接方式
    NSString *identifier = [self resolveStringArrayWithArray:ids];
    if (ids.count == 1) {
        path = [path stringByAppendingPathComponent:identifier];
    }else{
        path = [path stringByAppendingString:identifier];
    }
    NSMutableURLRequest *request = (NSMutableURLRequest*)[self createRequestWithURLString:path setupUserToken:YES];

    //设置add and delete 请求方法
    switch (type) {
        case ManageDeleteMusicVideoRatingsType:
        case ManageDeleteAlbumRatingsType:
        case ManageDeleteStationRatingsType:
        case ManageDeletePlaylistRatingsType:
        case ManageDeleteSongRatingsType:
            [request setHTTPMethod:@"DELETE"];
            break;

        //增加评价
        case ManageAddStationRatingsType:
        case ManageAddSongRatingsType:
        case ManageAddAlbumRatingsType:
        case ManageAddPlaylistRatingsType:
        case ManageAddMusicVideoRatingsType:
            [request setHTTPMethod:@"PUT"];
            //增加请求 设置请求体
            request = [self changeRatingRequestWithReuqest:request isLikes:likes];
            break;
            
        default:
            break;
    }
    return request;
}

/**设置请求评价他请求体*/
-(NSMutableURLRequest*)changeRatingRequestWithReuqest:(NSMutableURLRequest*)request isLikes:(BOOL)likes{
    NSDictionary *dict ;
    if (likes) {
        dict = @{@"type":@"rating",@"attributes":@{@"value":@1}};
    }else{
        dict = @{@"type":@"rating",@"attributes":@{@"value":@(-1)}};
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingSortedKeys error:nil] ;
    [request setHTTPBody:data];
    Log(@"Body Dict:%@  Body Data:%@",dict,data);
    return request;
}

@end
