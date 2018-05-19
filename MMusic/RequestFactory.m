//
//  RequestFactory.m
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "RequestFactory.h"
#import "AuthorizationManager.h"


@interface RequestFactory()
/**根路径*/
@property(nonatomic, copy) NSString *rootPath;
/**当前用户地区商店代码*/
@property(nonatomic, copy) NSString *storefront;
@end

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

-(NSURLRequest *)createRequestWithHref:(NSString *)href{
    NSString *path = @"https://api.music.apple.com";
    path = [path stringByAppendingPathComponent:href];
    return [self createRequestWithURLString:path setupUserToken:NO];
}

@end

#pragma mark - 获取资源分类
@implementation RequestFactory(FetchResource)
-(NSURLRequest *)fetchResourceFromType:(ResourceType)type andIds:(NSArray<NSString *> *)ids{
    NSString *path = self.rootPath;
    NSString *subPath = [self subPathFromType:type];
    path = [path stringByAppendingPathComponent:subPath];
    if (ids.count == 1) {
        path = [path stringByAppendingPathComponent:ids.firstObject];
    }else if(ids.count > 1) {
        path = [path stringByAppendingString:@"?ids="];
        for (NSString *identifier in ids) {
            NSString *arg = [identifier stringByAppendingString:@","];
            [path stringByAppendingString:arg];
        }
    }
    return [self createRequestWithURLString:path setupUserToken:NO];
}
-(NSString*) subPathFromType:(ResourceType) type{
    NSString *subPath;
    switch (type) {
        case ResourceSongsType:
            subPath = @"songs";
            break;
        case ResourceAlbumsType:
            subPath = @"albums";
            break;
        case ResourcePlaylistsType:
            subPath = @"playlists";
            break;
        case ResourceMusicVideosType:
            subPath = @"music-videos";
            break;
        case ResourceArtistsType:
            subPath = @"artists";
            break;
        case ResourceCuratorsType:
            subPath = @"curators";
            break;
        case ResourceStationsType:
            subPath = @"stations";
            break;
        case ResourceActivitiesType:
            subPath = @"activities";
            break;
        case ResourceAppleCuratorsType:
            subPath = @"apple-curators";
            break;
    }
    return subPath;
}
@end

#pragma mark - 获取排行榜分类
@implementation RequestFactory(FetchCharts)
-(NSURLRequest *)fetchChartsFromType:(ChartsType)type{
    NSString *path = [self.rootPath stringByAppendingPathComponent:@"charts?types="];
    switch (type) {
        case ChartsSongsType:
            path = [path stringByAppendingString:@"songs,"];
            break;
        case ChartsPlaylistsType:
            path = [path stringByAppendingString:@"playlists,"];
            break;
        case ChartsAlbumsType:
            path = [path stringByAppendingString:@"albums,"];
            break;
        case ChartsMusicVideosType:
            path = [path stringByAppendingString:@"music-videos,"];
            break;
    }
    
    return [self createRequestWithURLString:path setupUserToken:NO];
}
@end


#pragma mark - 搜索分类
@implementation RequestFactory(SearchCatalog)
-(NSURLRequest *)createSearchWithText:(NSString *)text{
    return [self searchCatalogResourcesForText:text forType:SearchDefaultsType];
}

-(NSURLRequest *)searchCatalogResourcesForText:(NSString *)text forType:(SearchType)type{
    NSString *path = [self.rootPath stringByAppendingPathComponent:@"search?term="];
    path = [path stringByAppendingString:text];
    path = [path stringByAppendingString:@"&limit=20"];

    if (type == SearchDefaultsType) {
        return [self createRequestWithURLString:path setupUserToken:NO];
    }else{
        NSString *str = [NSString string];
        if (type & SearchAlbumsType)       str = [str stringByAppendingString:@"albums,"];
        if (type & SearchPlaylistsType)    str = [str stringByAppendingString:@"playlists,"];
        if (type & SearchSongsType)        str = [str stringByAppendingString:@"songs,"];
        if (type & SearchMusicVideosType)  str = [str stringByAppendingString:@"music-videos,"];
        if (type & SearchStationsType)     str = [str stringByAppendingString:@"stations,"];
        if (type & SearchCuratorsType)     str = [str stringByAppendingString:@"curators,"];
        if (type & SearchAppleCuratorsType)str = [str stringByAppendingString:@"apple-curators,"];
        if (type & SearchArtisrsType)      str = [str stringByAppendingString:@"artists,"];
        if (type & SearchActivitiesType)   str = [str stringByAppendingString:@"activities,"];

        path = [path stringByAppendingString:@"&types="];
        path = [path stringByAppendingString:str];
        return [self createRequestWithURLString:path setupUserToken:NO];
    }
}
-(NSURLRequest *)fetchSearchHintsForTerms:(NSString *)text{
    NSString *path = [self.rootPath stringByAppendingPathComponent:@"search/hints?term="];
    path = [path stringByAppendingString:text];
    return [self createRequestWithURLString:path setupUserToken:NO];
}


@end


