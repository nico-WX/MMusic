//
//  RequestFactory.m
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "RequestFactory.h"
#import "AuthorizationManager.h"
#import "NSObject+Tool.h"

extern NSString *userTokenUserDefaultsKey ;
extern NSString *developerTokenDefaultsKey;
extern NSString *storefrontDefaultsKey;

@implementation RequestFactory

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
    }
    return string;
}

/**解析排行榜类型参数*/
-(NSString*) resolveStringWithChartType:(ChartsType) type{
    switch (type) {
        case ChartsSongsType:
            return @"songs";
            break;
        case ChartsAlbumsType:
            return @"albums";
            break;
        case ChartsMusicVideosType:
            return @"music-videos";
            break;
        case ChartsPlaylistsType:
            return @"playlists";
            break;
    }
}

/**解析搜索类型*/
-(NSString*)resolveSearchType:(SearchType) types{
    if (types == SearchDefaultsType) return nil;

    NSString *str = [NSString string];
    if (types & SearchAlbumsType)       str = [str stringByAppendingString:@"albums,"];
    if (types & SearchPlaylistsType)    str = [str stringByAppendingString:@"playlists,"];
    if (types & SearchSongsType)        str = [str stringByAppendingString:@"songs,"];
    if (types & SearchMusicVideosType)  str = [str stringByAppendingString:@"music-videos,"];
    if (types & SearchStationsType)     str = [str stringByAppendingString:@"stations,"];
    if (types & SearchCuratorsType)     str = [str stringByAppendingString:@"curators,"];
    if (types & SearchAppleCuratorsType)str = [str stringByAppendingString:@"apple-curators,"];
    if (types & SearchArtisrsType)      str = [str stringByAppendingString:@"artists,"];
    if (types & SearchActivitiesType)   str = [str stringByAppendingString:@"activities,"];
    return str;
}

/**解析字符串数组参数 并拼接返回*/
-(NSString *) resolveStringArrayWithArray:(NSArray<NSString*> *) ids{
    NSString *string = [NSString string];
    if (ids.count == 1) {
        string = ids.lastObject;
    }else{
        for (NSString *str in ids) string = [string stringByAppendingFormat:@"%@,",str];
    }
    return string;
}


-(NSURLRequest *)createRequestWithType:(RequestType)type resourceIds:(NSArray<NSString *> *)ids{
    //解析参数
    NSString *resourceType = [self resolveRequestType:type];
    NSString *identifier   = [self resolveStringArrayWithArray:ids];

    // 拼接路径,并判断请求单个或多个资源, 然后决定参数拼接方式
    NSString *path = [self.rootPath stringByAppendingPathComponent:resourceType];
    if (ids.count == 1) {
        path = [path stringByAppendingPathComponent:identifier];
    }else{
        path = [path stringByAppendingString:identifier];
    }
    //普通请求  不需要设置userToken
    return [self createRequestWithURLString:path setupUserToken:NO];
}

-(NSURLRequest *)createChartWithChartType:(ChartsType)type{
    //URL Map https://api.music.apple.com/v1/catalog/{storefront}/charts?types={types}
    NSString *typeStr = [self resolveStringWithChartType:type];
    NSString *path = [self.rootPath stringByAppendingPathComponent:@"charts?types="];
    //参数直接拼接 
    path = [path stringByAppendingString:typeStr];
    return [self createRequestWithURLString:path setupUserToken:NO];
}

/**通过搜索文本 创建搜索请求,限制数量limit=10*/
-(NSURLRequest *)createSearchWithText:(NSString *)searchText{
    NSString *path = [self.rootPath stringByAppendingPathComponent:@"search?term="];
    path = [path stringByAppendingString:searchText];
    path = [path stringByAppendingString:@"&limit=10"];
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

-(NSURLRequest *)createSearchWithText:(NSString *)searchText types:(SearchType)types{
    NSString *resourceTypes = [self resolveSearchType:types];
    NSString *path = [self.rootPath stringByAppendingPathComponent:@"search?term="];
    path = [path stringByAppendingString:searchText];
    path = [path stringByAppendingString:@"&limit=10"];
    path = [path stringByAppendingString:@"&types="];
    path = [path stringByAppendingString:resourceTypes];
    return [self createRequestWithURLString:path setupUserToken:NO];
}
@end
