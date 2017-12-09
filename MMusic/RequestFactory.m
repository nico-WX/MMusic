//
//  RequestFactory.m
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "RequestFactory.h"
#import "AuthorizationManager.h"

extern NSString *userTokenUserDefaultsKey ;
extern NSString *developerTokenDefaultsKey;
extern NSString *storefrontDefaultsKey;

@implementation RequestFactory
+(instancetype)requestFactory{
    return [[self alloc] init];
}
/**一般请求*/
-(instancetype)init{
    if (self = [super init]) {
        _storefront = [AuthorizationManager shareAuthorizationManager].storefront;
        //拼接前段路径
        _rootPath = @"https://api.music.apple.com";
        _rootPath = [_rootPath stringByAppendingPathComponent:@"v1"];
        _rootPath = [_rootPath stringByAppendingPathComponent:@"catalog"];
        _rootPath = [_rootPath stringByAppendingPathComponent:_storefront];
    }
    return self;
}

#pragma mark Tool Method
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

/**解析类型 并返回subPath*/
-(NSString *) resolveRequestType:(RequestType) type{
    NSString *string;
    switch (type) {
        case RequestAlbumType:
            string = @"albums";
            break;
        case RequestMultipleAlbumType:
            string = @"albums?ids=";
            break;
        case RequestMusicVideoType:
            string = @"music-videos";
            break;
        case RequestMultipleMusicVideoType:
            string = @"music-videos?ids=";
            break;
        case RequestPlaylistType:
            string = @"playlists";
            break;
        case RequestMultiplePlaylistType:
            string = @"playlists?ids=";
            break;
        case RequestSongType:
            string = @"songs";
            break;
        case  RequestMultipleSongType:
            string = @"songs?ids=";
            break;
        case RequestStationType:
            string = @"stations";
            break;
        case RequestMultipleStationType:
            string = @"stations?ids=";
            break;
        case RequestArtistType:
            string = @"artists";
            break;
        case RequestMultipleArtistType:
            string = @"artists?ids=";
            break;
        case RequestActivityType:
            string = @"activities";
            break;
        case RequestMultipleActivityType:
            string = @"activities?ids=";
            break;
        case RequestCuratorType:
            string = @"curators";
            break;
        case RequestMultipleCuratorType:
            string = @"curators?ids=";
            break;
        case RequestAppleCuratorType:
            string = @"apple-curators";
            break;
        case RequestMultipleAppleCuratorType:
            string = @"apple-curators?ids=";
            break;
        case RequestGenresType:
            string = @"genres";
            break;
        case RequestTopGenresType:
            string = @"genres";
            break;
        case RequestMultipleGenresType:
            string = @"genres?ids=";
            break;

        default:
            break;
    }
    return string;
}

/**解析排行榜类型参数*/
-(NSString*) resolveStringWithChartType:(ChartType) type{
    switch (type) {
        case ChartSongsType:
            return @"songs";
            break;
        case ChartAlbumsType:
            return @"albums";
            break;
        case ChartMusicVideosType:
            return @"music-videos";
            break;
        default:
            break;
    }
}

#pragma mark Implementation Create Request
-(NSURLRequest *)createRequestWithType:(RequestType)type resourceIds:(NSArray<NSString *> *)ids{
    //转换参数
    NSString *resourceType = [self resolveRequestType:type];
    NSString *identifier   = [self resolveStringArrayWithArray:ids];

    NSString *path = [self.rootPath stringByAppendingPathComponent:resourceType];
    //判断请求单个或多个资源, 并处理参数拼接方式
    if (ids.count == 1) {
        path = [path stringByAppendingPathComponent:identifier];
    }else{
        path = [path stringByAppendingString:identifier];
    }
    return [self createRequestWithURLString:path setupUserToken:NO];
}

-(NSURLRequest *)createChartWithChartType:(ChartType)type{
    //URL Map https://api.music.apple.com/v1/catalog/{storefront}/charts?types={types}
    NSString *typeStr = [self resolveStringWithChartType:type];
    NSString *path = [self.rootPath stringByAppendingPathComponent:@"charts?types="];
    //参数直接拼接 
    path = [path stringByAppendingString:typeStr];
    return [self createRequestWithURLString:path setupUserToken:NO];
}

-(NSURLRequest *)createSearchWithText:(NSString *)searchText{
    NSString *path = [self.rootPath stringByAppendingPathComponent:@"search?term="];
    path = [path stringByAppendingString:searchText];
    return [self createRequestWithURLString:path setupUserToken:NO];
}

-(NSURLRequest *)createSearchHintsWithTerm:(NSString *)term{
    NSString *path = [self.rootPath stringByAppendingPathComponent:@"search/hints?term="];
    path = [path stringByAppendingString:term];
    return [self createRequestWithURLString:path setupUserToken:NO];
}
-(NSURLRequest *)createRequestWithHerf:(NSString *)herf{
    NSString *path = @"https://api.music.apple.com";
    path = [path stringByAppendingPathComponent:herf];
    return [self createRequestWithURLString:path setupUserToken:NO];
}

@end
