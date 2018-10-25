//
//  Library.m
//  MMusic
//
//  Created by Magician on 2018/6/25.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import "Library.h"
#import "AuthorizationManager.h"

@interface Library()
@end

static Library* _instance;
@implementation Library

+(instancetype)allocWithZone:(struct _NSZone *)zone{
    if (!_instance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _instance = [super allocWithZone:zone];
        });
    }
    return _instance;
}

-(instancetype)init{
    if (self = [super init]) {
        self.rootPath = [self.rootPath stringByAppendingPathComponent:@"me"];
        self.rootPath = [self.rootPath stringByAppendingPathComponent:@"library"];
    }
    return self;
}


-(void)resource:(NSArray<NSString *> *)ids byType:(CLibrary)library callBack:(RequestCallBack)handle{

    NSString *subPath = [self subPathForType:library];
    NSString *path = [self.rootPath stringByAppendingPathComponent:subPath];
    if (ids) {
        if (ids.count == 1) {
            path = [path stringByAppendingPathComponent:ids.lastObject];
            path = [path stringByAppendingString:@"?include=tracks"];
        }
        if (ids.count > 1) {
            path = [path stringByAppendingString:@"?ids="];
            for (NSString *identifier in ids) {
                path = [path stringByAppendingString:[NSString stringWithFormat:@"%@,",identifier]];
            }
        }
    }

    NSURLRequest *request = [self createRequestWithURLString:path setupUserToken:YES];
    //Log(@"header %@",request.allHTTPHeaderFields);
    [self dataTaskWithRequest:request handler:handle];
}
-(void)relationship:(NSString *)identifier forType:(CLibrary)library byName:(NSString *)name callBacl:(RequestCallBack)handle{

    NSString *subPath = [self subPathForType:library];
    NSString *path = [self.rootPath stringByAppendingPathComponent:subPath];
    path = [path stringByAppendingPathComponent:identifier];
    path = [path stringByAppendingPathComponent:name];

    NSURLRequest *request = [self createRequestWithURLString:path setupUserToken:YES];
    [self dataTaskWithRequest:request handler:handle];
}

-(void)searchForTerm:(NSString *)term byType:(SLibrary)library callBack:(RequestCallBack)handle{

    NSString *path = [self.rootPath stringByAppendingPathComponent:@"search?term="];
    path = [path stringByAppendingString:term];
    path = [path stringByAppendingString:@"&types="];
    switch (library) {
        case SLibraryAlbums:
            path = [path stringByAppendingString:@"library-albums"];
            break;
        case SLibraryArtists:
            path = [path stringByAppendingString:@"library-artists"];
            break;
        case SLibraryPlaylists:
            path = [path stringByAppendingString:@"library-playlists"];
            break;
        case SLibrarySongs:
            path = [path stringByAppendingString:@"library-songs"];
            break;
        case SLibraryMusicVideos:
            path = [path stringByAppendingString:@"library-music-videos"];
            break;
    }

    NSURLRequest *request = [self createRequestWithURLString:path setupUserToken:YES];
    [self dataTaskWithRequest:request handler:handle];
}

-(void)heavyRotationContentInCallBack:(RequestCallBack)handle{
    NSString *path = [self.rootPath stringByReplacingOccurrencesOfString:@"library" withString:@"history"];
    path = [path stringByAppendingPathComponent:@"heavy-rotation"];

    NSURLRequest *request = [self createRequestWithURLString:path setupUserToken:YES];
    [self dataTaskWithRequest:request handler:handle];
}

-(void)recentlyPlayedInCallBack:(RequestCallBack)handle{
    NSString *path = [self.rootPath stringByReplacingOccurrencesOfString:@"library" withString:@"recent"];
    path = [path stringByAppendingPathComponent:@"played"];

    NSURLRequest *request = [self createRequestWithURLString:path setupUserToken:YES];
    [self dataTaskWithRequest:request handler:handle];
}
-(void)recentStationsInCallBack:(RequestCallBack)handle{
    NSString *path = [self.rootPath stringByReplacingOccurrencesOfString:@"library" withString:@"recent"];
    path = [path stringByAppendingPathComponent:@"radio-stations"];

    NSURLRequest *request = [self createRequestWithURLString:path setupUserToken:YES];
    [self dataTaskWithRequest:request handler:handle];
}
-(void)recentlyAddedToLibraryInCallBack:(RequestCallBack)handle{
    NSString *path = [self.rootPath stringByAppendingPathComponent:@"recently-added"];

    NSURLRequest *request = [self createRequestWithURLString:path setupUserToken:YES];
    [self dataTaskWithRequest:request handler:handle];
}
-(void)addResourceToLibraryForIdentifiers:(NSArray<NSString *> *)ids byType:(AddType)type callBack:(RequestCallBack)handle{
    NSString *path = [self.rootPath stringByAppendingString:@"?ids"];
    switch (type) {
        case AddAlbums:
            path = [path stringByAppendingString:@"[albums]="];
            break;
        case AddPlaylists:
            path = [path stringByAppendingString:@"[playlists]="];
            break;
        case AddMusicVideos:
            path = [path stringByAppendingString:@"[music-videos]="];
            break;
        case AddSongs:
            path = [path stringByAppendingString:@"[songs]="];
            break;
    }
    for (NSString *identifier in ids) {
        path = [path stringByAppendingString:[NSString stringWithFormat:@"%@,",identifier]];
    }

    NSMutableURLRequest *request = (NSMutableURLRequest*)[self createRequestWithURLString:path setupUserToken:YES];
    [request setHTTPMethod:@"POST"];

    //没有响应体 , 成功响应码:202
    [self dataTaskWithRequest:request handler:handle];
}

-(void)createNewLibraryPlaylistsForJsonPlayload:(NSDictionary *)json callBack:(RequestCallBack)handle{
    NSString *path = [self.rootPath stringByAppendingPathComponent:@"playlists"];
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingSortedKeys error:nil];

    NSMutableURLRequest *request = (NSMutableURLRequest*)[self createRequestWithURLString:path setupUserToken:YES];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:bodyData];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    [self dataTaskWithRequest:request handler:handle];
}


-(void)addTracksToLibraryPlaylists:(NSString *)identifier tracks:(NSArray<NSDictionary *> *)tracks callBack:(RequestCallBack)handle{
    NSString *path = [self.rootPath stringByAppendingPathComponent:@"playlists"];
    path = [path stringByAppendingPathComponent:identifier];
    path = [path stringByAppendingPathComponent:@"tracks"];
    NSDictionary *playload = @{@"data":tracks};
    NSData *data = [NSJSONSerialization dataWithJSONObject:playload options:NSJSONWritingSortedKeys error:nil];

    NSMutableURLRequest *request = (NSMutableURLRequest*)[self createRequestWithURLString:path setupUserToken:YES];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:data];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    //无响应体,  响应码:204
    [self dataTaskWithRequest:request handler:handle];
}


-(void)getRating:(NSArray<NSString *> *)ids byType:(CRating)type callBack:(RequestCallBack)handle{
    NSString *path = [self.rootPath stringByReplacingOccurrencesOfString:@"library" withString:@"ratings"];
    path = [path stringByAppendingPathComponent:[self subPathForRatingType:type]];
    if (ids.count == 1) {
        path = [path stringByAppendingPathComponent:ids.lastObject];
    }else if (ids.count > 1){
        path = [path stringByAppendingString:@"?ids="];
        for (NSString *identifier in ids) {
            path = [path stringByAppendingString:[NSString stringWithFormat:@"%@,",identifier]];
        }
    }

    NSURLRequest *request = [self createRequestWithURLString:path setupUserToken:YES];
    [self dataTaskWithRequest:request handler:handle];
}
-(void)addRating:(NSString *)identifier byType:(CRating)type value:(int)value callBack:(RequestCallBack)handle{
    NSString *path = [self.rootPath stringByReplacingOccurrencesOfString:@"library" withString:@"ratings"];
    path = [path stringByAppendingPathComponent:[self subPathForRatingType:type]];
    path = [path stringByAppendingPathComponent:identifier];

    //请求体
    NSDictionary *playload = @{@"type":@"rating",@"attributes":@{@"value":[NSNumber numberWithInt:value]}};
    NSData *data = [NSJSONSerialization dataWithJSONObject:playload options:NSJSONWritingSortedKeys error:nil];

    NSMutableURLRequest *request = (NSMutableURLRequest*)[self createRequestWithURLString:path setupUserToken:YES];
    [request setHTTPMethod:@"PUT"];
    [request setHTTPBody:data];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    [self dataTaskWithRequest:request handler:handle];
}

-(void)deleteRating:(NSString *)identifier byType:(CRating)type callBack:(RequestCallBack)handle{
    NSString *path = [self.rootPath stringByReplacingOccurrencesOfString:@"library" withString:@"ratings"];
    path = [path stringByAppendingPathComponent:[self subPathForRatingType:type]];
    path = [path stringByAppendingPathComponent:identifier];

    NSMutableURLRequest *request = (NSMutableURLRequest*)[self createRequestWithURLString:path setupUserToken:YES];
    [request setHTTPMethod:@"DELETE"];

    //无响应体, 成功响应码:204
    [self dataTaskWithRequest:request handler:handle];
}


-(void)defaultRecommendationsInCallBack:(RequestCallBack)handle{
    NSString *path = [self.rootPath stringByReplacingOccurrencesOfString:@"library" withString:@"recommendations"];
    NSURLRequest *request = [self createRequestWithURLString:path setupUserToken:YES];
    [self dataTaskWithRequest:request handler:handle];
}

#pragma  mark - helper
-(NSString*)subPathForRatingType:(CRating) rating{
    NSString *subPath = @"";
    switch (rating) {
        case CRatingAlbums:
            subPath = @"albums";
            break;
        case CRatingPlaylists:
            subPath = @"playlists";
            break;
        case CRatingMusicVideos:
            subPath = @"music-videos";
            break;
        case CRatingSongs:
            subPath = @"songs";
            break;
        case CRatingStations:
            subPath = @"stations";
            break;
    }
    return subPath;
}
-(NSString*)subPathForType:(CLibrary)library{
    NSString *subPath = @"";
    switch (library) {
        case CLibraryAlbums:
            subPath = @"albums";
            break;
        case CLibraryArtists:
            subPath = @"artists";
            break;
        case CLibraryPlaylists:
            subPath = @"playlists";
            break;
        case CLibraryMusicVideos:
            subPath = @"music-videos";
            break;
        case CLibrarySongs:
            subPath = @"songs";
            break;
    }
    return subPath;
}

@end
