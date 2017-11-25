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
            string = @"recommendations";
            break;
        case PersonalizedAlbumRecommendationsType:
            string = @"recommendations?type=albums";
            break;
        case PersonalizedPlaylistRecommendationsType:
            string = @"recommendations?type=playlists";
            break;
        case PersonalizedRecommendationType:
            string = @"recommendations";
            break;
        case PersonalizedMultipleRecommendationType:
            string = @"recommendations?ids=";
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
    if (type == PersonalizedRecommendationType) {
        NSString *identifier = [self resolveStringArrayWithArray:ids];
        path = [path stringByAppendingPathComponent:identifier];
    }else if(type == PersonalizedMultipleRecommendationType){
        NSString *identifier = [self resolveStringArrayWithArray:ids];
        path = [path stringByAppendingString:identifier];
    }
    return  [self createRequestWithURLString:path setupUserToken:YES];
}

@end
