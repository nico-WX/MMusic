//
//  Library.m
//  MMusic
//
//  Created by Magician on 2018/6/25.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import "Library.h"
#import "AuthManager.h"

@interface Library()
@end

static Library* _instance;
@implementation Library

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

- (instancetype)init{
    if (self = [super init]) {
        _libraryPath = [self.rootPath stringByAppendingPathComponent:@"me"];
    }
    return self;
}


- (void)resource:(NSArray<NSString *> *)ids byType:(LibraryResourceType)library callBack:(RequestCallBack)handle {

    NSString *subPath = @"library";
    subPath = [subPath stringByAppendingPathComponent:[self subPathForType:library]];

    NSString *path = [self.libraryPath stringByAppendingPathComponent:subPath];
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
    NSLog(@"path =%@",path);

    NSURLRequest *request = [self createRequestWithURLString:path setupUserToken:YES];
    //Log(@"header %@",request.allHTTPHeaderFields);
    [self dataTaskWithRequest:request handler:handle];
}

- (void)relationship:(NSString *)identifier forType:(LibraryResourceType)library byName:(NSString *)name callBacl:(RequestCallBack)handle {

    NSString *subPath = [self subPathForType:library];
    NSString *path = [self.rootPath stringByAppendingPathComponent:subPath];
    path = [path stringByAppendingPathComponent:identifier];
    path = [path stringByAppendingPathComponent:name];

    NSURLRequest *request = [self createRequestWithURLString:path setupUserToken:YES];
    [self dataTaskWithRequest:request handler:handle];
}

- (void)searchForTerm:(NSString *)term byType:(SearchLibraryType)library callBack:(RequestCallBack)handle {

    NSString *path = [self.libraryPath stringByAppendingPathComponent:@"library/search?term="];
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


- (void)defaultRecommendationsInCallBack:(RequestCallBack)handle {
    NSString *path = [self.libraryPath stringByAppendingPathComponent:@"recommendations"];
    NSURLRequest *request = [self createRequestWithURLString:path setupUserToken:YES];
    [self dataTaskWithRequest:request handler:handle];
}

#pragma  mark - helper

- (NSString*)subPathForType:(LibraryResourceType)library {
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
            NSLog(@"MV =========");
            break;
        case CLibrarySongs:
            subPath = @"songs";
            break;
    }
    return subPath;
}

@end
