//
//  MusicKitTest.m
//  MMusic
//
//  Created by Magician on 2018/6/26.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MusicKit.h"

@interface MusicKitTest : XCTestCase

@end

@implementation MusicKitTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

-(void)testAPI{
    MusicKit *music = [MusicKit new];
    NSString *song      = @"1333861909";
    NSString *album     = @"1334842987";
//    NSString *playlist  = @"";
//    NSString *mv        = @"";
//    NSString *artist    = @"368183298";
//    NSString *station   = @"";


    [music.api resources:@[song,] byType:CatalogSongs callBack:^(NSDictionary *json, NSHTTPURLResponse *response) {

        if (response.statusCode/10 == 20 ) {
            XCTAssert(true,@"返回数据");
        }else{
            XCTFail(@"失败");
        }
    }];
    [music.api resources:@[album,] byType:CatalogAlbums callBack:^(NSDictionary *json, NSHTTPURLResponse *response) {
        if (response.statusCode/10 ==20) {
            XCTAssert(true,@"返回数据");
        }else{
            XCTFail(@"失败");
        }
    }];


}

@end
