//
//  Catalog+Search.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/11.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import "Catalog+Search.h"
#import "NSURLRequest+CreateURLRequest.h"

@implementation Catalog (Search)

//GET https://api.music.apple.com/v1/catalog/{storefront}/search
- (void)searchForTerm:(NSString *)term callBack:(RequestCallBack)handle {
    NSString *path = [self.catalogPath stringByAppendingPathComponent:@"search?term="];
    path = [path stringByAppendingString:term];

    //每页15 条数
    path = [path stringByAppendingString:@"&limit=15"];

    NSURLRequest *request = [NSURLRequest createRequestWithURLString:path setupUserToken:NO];
    [self dataTaskWithRequest:request handler:handle];
}
// get https://api.music.apple.com/v1/catalog/{storefront}/search/hints?term=love&limit=10
- (void)searchHintsForTerm:(NSString *)term callBack:(RequestCallBack)handle {
    NSString *path = [self.catalogPath stringByAppendingPathComponent:@"search/hints?term="];
    path = [path stringByAppendingString:term];
    NSURLRequest *request = [NSURLRequest createRequestWithURLString:path setupUserToken:NO];
    [self dataTaskWithRequest:request handler:handle];
}

@end
