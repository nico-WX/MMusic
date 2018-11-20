//
//  MMSearchBarController.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/17.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import "MMSearchBarController.h"
#import "SearchViewController.h"

@interface MMSearchBarController()<UISearchBarDelegate>
@property(nonatomic, strong)SearchViewController *searchViewController;
@end

@implementation MMSearchBarController

- (instancetype)init {
    if (self = [super init]) {
        _searchBar = [[UISearchBar alloc] init];
        [_searchBar setDelegate:self];

        _searchViewController = [[SearchViewController alloc] init];
    }
    return self;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    [self presentViewController:_searchViewController animated:YES completion:nil];
    return YES;
}


@end
