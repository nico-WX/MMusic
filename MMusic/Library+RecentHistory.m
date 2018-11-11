//
//  Library+RecentHistory.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/11.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import "Library+RecentHistory.h"

@implementation Library (RecentHistory)


//GET https://api.music.apple.com/v1/me/history/heavy-rotation
- (void)heavyRotationContentInCallBack:(RequestCallBack)handle {
    NSString *path = [self.libraryPath  stringByAppendingPathComponent:@"history/heavy-rotation"];
    NSURLRequest *request = [self createRequestWithURLString:path setupUserToken:YES];
    [self dataTaskWithRequest:request handler:handle];
}

//GET https://api.music.apple.com/v1/me/recent/played
- (void)recentlyPlayedInCallBack:(RequestCallBack)handle {
    NSString *path = [self.libraryPath  stringByAppendingPathComponent:@"recent/played"];
    NSURLRequest *request = [self createRequestWithURLString:path setupUserToken:YES];
    [self dataTaskWithRequest:request handler:handle];
}

//GET https://api.music.apple.com/v1/me/recent/radio-stations
- (void)recentStationsInCallBack:(RequestCallBack)handle {
    NSString *path = [self.libraryPath  stringByAppendingPathComponent:@"recent/radio-stations"];

    NSURLRequest *request = [self createRequestWithURLString:path setupUserToken:YES];
    [self dataTaskWithRequest:request handler:handle];
}

//GET https://api.music.apple.com/v1/me/library/recently-added
- (void)recentlyAddedToLibraryInCallBack:(RequestCallBack)handle {
    NSString *path = [self.libraryPath  stringByAppendingPathComponent:@"library/recently-added"];
    NSURLRequest *request = [self createRequestWithURLString:path setupUserToken:YES];
    [self dataTaskWithRequest:request handler:handle];
}
@end
