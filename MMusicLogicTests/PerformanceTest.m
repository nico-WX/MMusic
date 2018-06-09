//
//  PerformanceTest.m
//  MMusicLogicTests
//
//  Created by Magician on 2018/5/21.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ChartsPageViewController.h"
#import "BrowseViewController.h"

@interface PerformanceTest : XCTestCase


@end

@implementation PerformanceTest

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


-(void) testCharts{

    [self measureBlock:^{
         ChartsPageViewController *pvc = [[ChartsPageViewController alloc] init];
        Log(@"sub =%@",pvc.childViewControllers);
    }];
}


-(void)testBrowse{
    [self measureBlock:^{
          BrowseViewController *bvc = [[BrowseViewController alloc] init];
        Log(@"sub =%@",bvc.childViewControllers);
    }];

}




@end
