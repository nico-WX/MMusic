//
//  RequestFactoryTest.m
//  MMusicLogicTests
//
//  Created by Magician on 2018/5/21.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSObject+Tool.h"
#import "RequestFactory.h"
#import "PersonalizedRequestFactory.h"




/**
 请求 异步 等测试
 */
@interface RequestFactoryTest : XCTestCase
@property(nonatomic, strong) XCTestExpectation *expectation;
@end

@implementation RequestFactoryTest

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

-(void) testRequest{
    self.expectation = [self expectationWithDescription:@"异步请求测试"];

    //异步请求
    NSURLRequest *request = [[RequestFactory new] createSearchWithText:@"周杰伦"];
    [self dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *res = (NSHTTPURLResponse*) response;
   
        if (res.statusCode ==  200) {
            [self.expectation fulfill];
            XCTAssert(true, @"搜索到数据成功");
        }else{
            XCTFail(@"搜索失败");
        }
    }];


    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {

    }];

}


@end
