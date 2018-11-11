//
//  Library+iCloud.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/11.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import "Library+iCloud.h"

@implementation Library (iCloud)



//Add a Resource to a Library
//POST https://api.music.apple.com/v1/me/library?ids[albums]=1106659171&ids[songs]=1107054256&ids[music-videos]=267079116
- (void)addResourceToLibraryForIdentifiers:(NSArray<NSString *> *)ids byType:(AddType)type callBack:(RequestCallBack)handle {

    NSString *path = [self.libraryPath stringByAppendingPathComponent:@"library?ids"];
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


//Create a New Library Playlist
// POST https://api.music.apple.com/v1/me/library/playlists
- (void)createNewLibraryPlaylistsForJsonPlayload:(NSDictionary *)json callBack:(RequestCallBack)handle {
    NSString *path = [self.libraryPath stringByAppendingPathComponent:@"library/playlists"];

    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingSortedKeys error:nil];
    NSMutableURLRequest *request = (NSMutableURLRequest*)[self createRequestWithURLString:path setupUserToken:YES];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:bodyData];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [self dataTaskWithRequest:request handler:handle];
}


//Add Tracks to a Library Playlist
// post https://api.music.apple.com/v1/me/library/playlists/p.zp6KqKxsoQWAGN/tracks
- (void)addTracksToLibraryPlaylists:(NSString *)identifier tracks:(NSArray<NSDictionary *> *)tracks callBack:(RequestCallBack)handle {
    NSString *path = [self.libraryPath stringByAppendingPathComponent:@"library/playlists"];
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
@end
