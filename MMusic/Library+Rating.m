//
//  Library+Rating.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/11.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import "Library+Rating.h"


static NSString *const ratingPath = @"ratings";
@implementation Library (Rating)

- (void)addRatingToCatalogWith:(NSString*)identifier type:(RTRatingType)type responseHandle:(RequestCallBack)callBack{

    NSString *path = [self makePathWith:identifier type:type];

    //请求体
    NSDictionary *playload = @{@"type":@"rating",@"attributes":@{@"value":[NSNumber numberWithInt:1]}};
    NSData *data = [NSJSONSerialization dataWithJSONObject:playload options:NSJSONWritingSortedKeys error:nil];

    NSMutableURLRequest *request = (NSMutableURLRequest*)[self createRequestWithURLString:path setupUserToken:YES];
    [request setHTTPMethod:@"PUT"];
    [request setHTTPBody:data];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [self dataTaskWithRequest:request handler:callBack];
}
- (void)deleteRatingForCatalogWith:(NSString*)identifier type:(RTRatingType)type responseHandle:(RequestCallBack)callBack{
    NSString *path = [self makePathWith:identifier type:type];

    NSMutableURLRequest *request = (NSMutableURLRequest*)[self createRequestWithURLString:path setupUserToken:YES];
    [request setHTTPMethod:@"DELETE"];

    //无响应体, 成功响应码:204
    [self dataTaskWithRequest:request handler:callBack];
}
- (void)requestRatingForCatalogWith:(NSString*)identifier type:(RTRatingType)type responseHandle:(RequestCallBack)callBack{
    NSString *path = [self makePathWith:identifier type:type];
    NSURLRequest *request = [self createRequestWithURLString:path setupUserToken:YES];
    [self dataTaskWithRequest:request handler:callBack];
}

- (NSString*)makePathWith:(NSString*)identifier type:(RTRatingType)type {
    //catalog
    //PUT https://api.music.apple.com/v1/me/ratings/albums/{id}
    //library
    //PUT https://api.music.apple.com/v1/me/ratings/library-playlists/{id}

    NSString *path = [self.libraryPath stringByAppendingPathComponent:ratingPath];
    path = [path stringByAppendingPathComponent:[self subPathForType:type]];
    path = [path stringByAppendingPathComponent:identifier];
    return path;
}

//替换枚举值
- (NSString*)subPathForType:(RTRatingType)type {
    NSString *subPath;
    switch (type) {
        case RTCatalogSongs:
            subPath = @"songs";
            break;
        case RTCatalogAlbums:
            subPath = @"albums";
            break;
        case RTCatalogStations:
            subPath = @"stations";
            break;
        case RTCatalogPlaylists:
            subPath = @"playlists";
            break;
        case RTCatalogMusicVideos:
            subPath = @"music-videos";
            break;

        case RTLibrarySongs:
            subPath = @"library-songs";
            break;
        case RTLibraryPlaylists:
            subPath = @"library-playlists";
            break;
        case RTLibraryMusicVideos:
            subPath = @"library-music-videos";
            break;
    }
    return subPath;
}
@end
