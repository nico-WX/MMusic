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

//        self.rootPath = [self.rootPath stringByAppendingPathComponent:@"me"];
//        self.rootPath = [self.rootPath stringByAppendingPathComponent:@"library"];
    }
    return self;
}


- (void)resource:(NSArray<NSString *> *)ids byType:(CLibrary)library callBack:(RequestCallBack)handle {

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

- (void)relationship:(NSString *)identifier forType:(CLibrary)library byName:(NSString *)name callBacl:(RequestCallBack)handle {

    NSString *subPath = [self subPathForType:library];
    NSString *path = [self.rootPath stringByAppendingPathComponent:subPath];
    path = [path stringByAppendingPathComponent:identifier];
    path = [path stringByAppendingPathComponent:name];

    NSURLRequest *request = [self createRequestWithURLString:path setupUserToken:YES];
    [self dataTaskWithRequest:request handler:handle];
}

- (void)searchForTerm:(NSString *)term byType:(SLibrary)library callBack:(RequestCallBack)handle {

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





- (void)defaultRecommendationsInCallBack:(RequestCallBack)handle {
    NSString *path = [self.rootPath stringByReplacingOccurrencesOfString:@"library" withString:@"recommendations"];
    NSURLRequest *request = [self createRequestWithURLString:path setupUserToken:YES];
    [self dataTaskWithRequest:request handler:handle];
}

#pragma  mark - helper

- (NSString*)subPathForType:(CLibrary)library {
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
