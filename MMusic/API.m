//
//  API.m
//  MMusic
//
//  Created by Magician on 2018/6/25.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import "API.h"
#import "AuthorizationManager.h"

@interface API()
@property(nonatomic, strong) NSString *rootPath;

@end

@implementation API

-(instancetype)init{
    if (self =[super init]) {
        _library = [[Library alloc] init];

        _rootPath = @"https://api.music.apple.com";
        _rootPath = [_rootPath stringByAppendingPathComponent:@"v1"];
        _rootPath = [_rootPath stringByAppendingPathComponent:@"catalog"];

        NSString *storeFront = [AuthorizationManager shareAuthorizationManager].storefront;
        _rootPath = [_rootPath stringByAppendingPathComponent:storeFront];
    }
    return self;
}


-(void)resources:(NSArray<NSString *> *)ids byType:(Catalog)catalog callBack:(void (^)(NSDictionary *))handle{
    NSString *subPath = [self subPathForType:catalog];
    NSString *path = [self.rootPath stringByAppendingPathComponent:subPath];
    if (ids.count == 1) {
        path = [path stringByAppendingPathComponent:ids.lastObject];
    }else{
        path = [path stringByAppendingString:@"?ids="];
        for (NSString* identifier in ids) {
            path = [path stringByAppendingString:[NSString stringWithFormat:@"%@,",identifier]];
        }
    }


    NSURLRequest *request = [self createRequestWithURLString:path setupUserToken:NO];
    [self datataskWithRequest:request completionHandler:^(NSDictionary *json) {
        if (handle) {
            handle(json);
        }
    }];
}
-(void)relationship:(NSString *)identifier byType:(Catalog)catalog forName:(NSString *)name callBack:(void (^)(NSDictionary *))handle{
    NSString *subPath = [self subPathForType:catalog];
    NSString *path = [self.rootPath stringByAppendingPathComponent:subPath];
    path = [path stringByAppendingPathComponent:identifier];
    path = [path stringByAppendingPathComponent:name];

    NSURLRequest *request = [self createRequestWithURLString:path setupUserToken:NO];
    [self datataskWithRequest:request completionHandler:^(NSDictionary *json) {
        if (handle) {
            handle(json);
        }
    }];
}
-(void)musicVideosByISRC:(NSArray<NSString *> *)ISRCs callBack:(void (^)(NSDictionary *))handle{
    NSString *subPath = [self subPathForType:CatalogMusicVideos];
    NSString *path = [self.rootPath stringByAppendingPathComponent:subPath];
    path = [path stringByAppendingString:@"?filter[isrc]="];
    for (NSString *isrc in ISRCs) {
        path = [path stringByAppendingString:[NSString stringWithFormat:@"%@,",isrc]];
    }

    NSURLRequest *request = [self createRequestWithURLString:path setupUserToken:NO];
    [self datataskWithRequest:request completionHandler:^(NSDictionary *json) {
        if (handle) {
            handle(json);
        }
    }];
}
-(void)songsByISRC:(NSArray<NSString *> *)ISRCs callBack:(void (^)(NSDictionary *))handle{
    NSString *subPath = [self subPathForType:CatalogSongs];
    NSString *path = [self.rootPath stringByAppendingPathComponent:subPath];
    path = [path stringByAppendingString:@"?filter[isrc]="];
    for (NSString *isrc in ISRCs) {
        path = [path stringByAppendingString:[NSString stringWithFormat:@"%@,",isrc]];
    }

    NSURLRequest *request = [self createRequestWithURLString:path setupUserToken:NO];
    [self datataskWithRequest:request completionHandler:^(NSDictionary *json) {
        if (handle) {
            handle(json);
        }
    }];
}

-(void)chartsByType:(ChartsType)type callBack:(void (^)(NSDictionary *))handle{
    NSString *path = [self.rootPath stringByAppendingPathComponent:@"charts?types="];
    switch (type) {
        case ChartsAlbums:
            path = [path stringByAppendingString:@"albums"];
            break;
        case ChartsPlaylists:
            path = [path stringByAppendingString:@"playlists"];
            break;
        case ChartsSongs:
            path = [path stringByAppendingString:@"songs"];
            break;
        case ChartsMusicVideos:
            path = [path stringByAppendingString:@"music-videos"];
            break;
    }

    NSURLRequest *request = [self createRequestWithURLString:path setupUserToken:NO];
    [self datataskWithRequest:request completionHandler:^(NSDictionary *json) {
        if (handle) {
            handle(json);
        }
    }];
}

-(void)searchForTerm:(NSString *)term callBack:(void (^)(NSDictionary *))handle{
    NSString *path = [self.rootPath stringByAppendingPathComponent:@"search?term="];
    path = [path stringByAppendingString:term];

    NSURLRequest *request = [self createRequestWithURLString:path setupUserToken:NO];
    [self datataskWithRequest:request completionHandler:^(NSDictionary *json) {
        if (handle) {
            handle(json);
        }
    }];
}
-(void)searchHintsForTerm:(NSString *)term callBack:(void (^)(NSDictionary *))handle{
    NSString *path = [self.rootPath stringByAppendingPathComponent:@"search"];
    path = [path stringByAppendingPathComponent:@"hints?term="];
    path = [path stringByAppendingString:term];

    NSURLRequest *request = [self createRequestWithURLString:path setupUserToken:NO];
    [self datataskWithRequest:request completionHandler:^(NSDictionary *json) {
        if (handle) {
            handle(json);
        }
    }];

}

#pragma mark - helper


//不同的类型,返回不同的子路径
-(NSString*)subPathForType:(Catalog) catalog{
    NSString *subPath = @"";
    switch (catalog) {
        case CatalogAlbums:
            subPath = @"albums";
            break;
        case CatalogArtists:
            subPath = @"artists";
            break;
        case CatalogActivities:
            subPath = @"activities";
            break;
        case CatalogAppleCurators:
            subPath = @"apple-curators";
            break;
        case CatalogCurators:
            subPath = @"curators";
            break;
        case CatalogPlaylists:
            subPath = @"playlists";
            break;
        case CatalogMusicVideos:
            subPath = @"music-videos";
            break;
        case CatalogSongs:
            subPath = @"songs";
            break;
        case CatalogStations:
            subPath = @"stations";
            break;
    }
    return subPath;
}


@end
