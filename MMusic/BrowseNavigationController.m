//
//  BrowseNavigationController.m
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "BrowseNavigationController.h"
#import <objc/NSObjCRuntime.h>


@interface BrowseNavigationController ()

@end

@implementation BrowseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    id test = @"aaaa";
    const char *name = object_getClassName(test);

    BOOL b = [test isKindOfClass:[NSString class]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
