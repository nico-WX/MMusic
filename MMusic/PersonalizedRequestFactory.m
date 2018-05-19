//
//  PersonalizedRequestFactory.m
//  MMusic
//
//  Created by Magician on 2017/11/25.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "PersonalizedRequestFactory.h"
#import "NSObject+Tool.h"

@interface PersonalizedRequestFactory()
/**根路径*/
@property(nonatomic,copy) NSString *rootPath;
@end

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

@end


#pragma mark - PersonalizedRequestFactory(FetchLirraryResource)
/**获取库资源*/
@implementation PersonalizedRequestFactory(FetchLibraryResource)

-(NSURLRequest*)fetchLibraryResourceWithType:(LibraryResourceType)type fromIds:(NSArray<NSString *> *)ids{
    NSString *subPath = [self stringFrom:type];
    NSString *path = self.rootPath;
    path = [path stringByAppendingPathComponent:subPath];

    if (ids.count == 0) {
        //全部
    }
    if (ids.count == 1) {
        //单个
        NSString *lastPath = ids.lastObject;
        path =[path stringByAppendingPathComponent:lastPath];
    }
    if (ids.count > 1) {
        //多个
        path = [path stringByAppendingString:@"?ids="];
        for (NSString *identifier in ids) {
            NSString *lastPath = [NSString stringWithFormat:@"%@,",identifier];
            path = [path stringByAppendingString:lastPath];
        }
    }
    return [self createRequestWithURLString:path setupUserToken:YES];
}


//辅助
-(NSString*)stringFrom:(LibraryResourceType) type{
    NSString *subPath;
    switch (type) {
        case LibraryResourceSongs:
            subPath = @"songs";
            break;
        case LibraryResourceAlbums:
            subPath = @"albums";
            break;

        case LibraryResourcePlaylists:
            subPath = @"playlists";
            break;
        case LibraryResourceMusicVideos:
            subPath = @"music-videos";
            break;

            case LibraryResourceArtists:
            subPath = @"artists";
            break;
    }
    return subPath;
}
@end

#pragma mark -  管理库资源实现
@implementation PersonalizedRequestFactory(ManagerLibrarySource)

-(NSURLRequest *)managerLibrarySourcesWithOperation:(ManagerLibraryOperation)operation
                                       resourceType:(LibraryResourceType)type
                                              andId:(NSString *)identifier {

    NSString *subPath = [self stringFrom:type];
    NSString *path = [self.rootPath stringByAppendingPathComponent:@"library"];

    //增加
    if (operation == ManagerLibraryAddOperation) {
        path = [path stringByAppendingString:@"?ids"];
        NSString *lastPath = [NSString stringWithFormat:@"[%@]=%@",subPath,identifier];
        path =[path stringByAppendingString:lastPath];

        NSMutableURLRequest *request = (NSMutableURLRequest*)[self createRequestWithURLString:path setupUserToken:YES];
        [request setHTTPMethod:@"POST"];
        return request;
    }else{
        //删除
        path = [path stringByAppendingPathComponent:subPath];
        path = [path stringByAppendingPathComponent:identifier];
        NSMutableURLRequest *request = (NSMutableURLRequest*)[self createRequestWithURLString:path setupUserToken:YES];
        [request setHTTPMethod:@"DELETE"];
        return request;
    }
}

@end


#pragma mark - 修改库播放列表实现
@implementation PersonalizedRequestFactory(ModifyLibraryPlaylists)

- (NSURLRequest *)modifyLibraryPlaylistsWithOperation:(ModifyOperationType)type
                                               fromId:(NSString *)playlistIdnetifier
                                       andJSONPayload:(NSDictionary *)jsonPlayload {

    NSString *path = [self.rootPath stringByAppendingPathComponent:@"library/playlists"];
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:jsonPlayload options:NSJSONWritingSortedKeys error:nil];

    switch (type) {
        case ModifyOperationCreateNewLibraryPlaylist:{

            NSMutableURLRequest *request = (NSMutableURLRequest*)[self createRequestWithURLString:path setupUserToken:YES ];
            [request setHTTPMethod:@"POST"];
            [request setHTTPBody:bodyData];
            return request;
        }
            break;

        case ModifyOperationReplaceLibraryPlaylistAttributes:{
            path = [path stringByAppendingPathComponent:playlistIdnetifier];
            NSMutableURLRequest *request = (NSMutableURLRequest*)[self createRequestWithURLString:path setupUserToken:YES];
            [request setHTTPMethod:@"PUT"];
            [request setHTTPBody:bodyData];
            return request;
        }
            break;

        case ModifyOperationUpdateLibraryPlaylistAttributes:{
            path = [path stringByAppendingPathComponent:playlistIdnetifier];
            NSMutableURLRequest *request = (NSMutableURLRequest*)[self createRequestWithURLString:path setupUserToken:YES];
            [request setHTTPBody:bodyData];
            [request setHTTPMethod:@"PATCH"];
            return request;
        }
            break;

        case ModifyOperationAddTracksToLibraryPlaylist:{
            path = [path stringByAppendingPathComponent:playlistIdnetifier];
            path = [path stringByAppendingPathComponent:@"tracks"];
            NSMutableURLRequest *request = (NSMutableURLRequest*)[self createRequestWithURLString:path setupUserToken:YES];
            [request setHTTPBody:bodyData];
            [request setHTTPMethod:@"POST"];
            return request;
        }
            break;

        case ModifyOperationReplaceTrackListForLibraryPlaylist:{
            path = [path stringByAppendingPathComponent:playlistIdnetifier];
            path = [path stringByAppendingPathComponent:@"tracks"];
            NSMutableURLRequest *request = (NSMutableURLRequest*)[self createRequestWithURLString:path setupUserToken:YES];
            [request setHTTPBody:bodyData];
            [request setHTTPMethod:@"PUT"];
            return request;
        }
            break;
    }
}

-(NSURLRequest *)deleteTracksFromLibraryPlaylistIdentifier:(NSString *)identifier types:(DeleteTrackType)type ids:(NSString *)deleteIdentifier mode:(DeleteMode)mode{

    //拼接参数
    NSString *path = [self.rootPath stringByAppendingPathComponent:@"library"];
    path = [path stringByAppendingPathComponent:@"playlists"];
    path = [path stringByAppendingPathComponent:identifier];
    path = [path stringByAppendingPathComponent:@"tracks?ids"];
    switch (type) {
        case DeleteLibrarySongsType:
            path = [path stringByAppendingString:@"[library-songs]="];
            break;
        case DeleteLibraryMusicVideosType:
            path = [path stringByAppendingString:@"[library-music-videos]="];
            break;
    }

    path = [path stringByAppendingString:deleteIdentifier];

    switch (mode) {
        case DeleteModeFirst:
            path = [path stringByAppendingString:@"&mode=first"];
            break;
        case DeleteModeLast:
            path = [path stringByAppendingString:@"&mode=last"];
            break;
        case DeleteModeAll:
            path = [path stringByAppendingString:@"&mode=all"];
            break;
    }
    NSMutableURLRequest *request = (NSMutableURLRequest*)[self createRequestWithURLString:path setupUserToken:YES];
    [request setHTTPMethod:@"DELETE"];
    return request;
}


@end

#pragma mark 管理Rating 实现
@implementation PersonalizedRequestFactory(ManagerRating)
-(NSURLRequest *)managerCatalogAndLibraryRatingsWithOperatin:(RatingsOperation)operation
                                               resourcesType:(ResourcesType)type
                                                      andIds:(NSArray<NSString *> *)ids{

    NSString *path = [self.rootPath stringByAppendingPathComponent:@"ratings"];

    //资源类型
    NSString *subPath = [self subPathFromType:type];
    path = [path stringByAppendingPathComponent:subPath];
    if (ids.count == 1) {
        path = [path stringByAppendingPathComponent:[ids lastObject]];
    }
    if (ids.count > 1) {
        path = [path stringByAppendingString:@"?ids="];
        for (NSString *identifier in ids) {
            NSString *ID = [NSString stringWithFormat:@"%@,",identifier];
            path = [path stringByAppendingString:ID];
        }
    }

    NSMutableURLRequest *request = (NSMutableURLRequest*)[self createRequestWithURLString:path setupUserToken:YES];
    switch (operation) {
        case RatingsAddOperation:{
            //添加 playload
            NSDictionary *dict = @{@"type":@"rating",@"attributes":@{@"value":@1}};
            NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingSortedKeys error:nil];
            [request setHTTPBody:data];
            [request setHTTPMethod:@"PUT"];
        }
            break;
        case RatingsGetOperation:{
            //默认GET
        }
            break;
        case RatingsDeleteOperation:{
            [request setHTTPMethod:@"DELETE"];
        }
            break;
    }

    return request;
}

-(NSString *) subPathFromType:(ResourcesType) type{
    switch (type) {
        case ResourcesPersonalAlbumType:{
            return @"albums";
        }
            break;
        case ResourcesPersonalStationType:{
            return @"stations";
        }
            break;
        case ResourcesPersonalSongType:{
            return @"songs";
        }
            break;
        case ResourcesPersonalLibrarySongType:{
            return @"library-songs";
        }
            break;
        case ResourcesPersonalPlaylistsType:{
            return @"playlists";
        }
            break;
        case ResourcesPersonalLibraryPlaylistsType:{
            return @"library-playlists";
        }
            break;

        case ResourcesPersonalMusicVideosType:{
            return @"music-videos";
        }
            break;
        case ResourcesPersonalLibraryMusicVideosType:{
            return @"library-music-videos";
        }
            break;
    }
}

@end

#pragma mark 获取推荐实现
@implementation PersonalizedRequestFactory(FetchRecommendations);

-(NSURLRequest *)fetchRecommendationsWithType:(FetchType)type andIds:(NSArray<NSString *> *)ids{
    NSString *path = [self.rootPath stringByAppendingPathComponent:@"recommendations"];

    switch (type) {
        case FetchDefaultRecommendationsType:{
            //默认直接请求
        }
            break;
        case FetchAlbumRecommendationsType:{
            path = [path stringByAppendingString:@"?type=albums"];
        }
            break;
        case FetchPlaylistRecommendationsType:{
            path = [path stringByAppendingString:@"?type=playlists"];
        }
            break;
        case FetchAnRecommendatinsType:{
            path = [path stringByAppendingPathComponent:ids.lastObject];
        }
            break;
        case FetchMultipleRecommendationsType:{
            path = [path stringByAppendingString:@"?ids="];
            NSString *lastPath;
            for (NSString *str in ids) {
                lastPath = [NSString stringWithFormat:@"%@,",str];
            }
            path = [path stringByAppendingString:lastPath];
        }
            break;
    }
    return [self createRequestWithURLString:path setupUserToken:YES];
}

@end

























