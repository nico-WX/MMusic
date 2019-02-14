//
//  MyMusicDataSource.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/27.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "MyMusicDataSource.h"

#import "MyLikeSongViewController.h"
#import "PodcastsViewController.h"
#import "LibrarySongViewController.h"
#import "DataManager.h"

@interface MyMusicDataSource ()<UITableViewDataSource>
@property(nonatomic,weak)id<MyMusicDataSourceDelegate> delegate;
@property(nonatomic,copy)NSString *identifier;
@property(nonatomic,strong)NSArray<UIViewController*> *lists;
@end

@implementation MyMusicDataSource


- (instancetype)initWithView:(UITableView *)tableView
                  identifier:(NSString *)identifier
                    delegate:(id<MyMusicDataSourceDelegate>)delegate{
    if (self = [super init]) {
        _identifier = identifier;
        _delegate = delegate;
        [tableView setDataSource:self];
        [self loadDataWithCompletion:^{
            [tableView reloadData];
        }];
    }
    return self;
}

- (void)loadDataWithCompletion:(void(^)(void))completion{

    MyLikeSongViewController *like = [[MyLikeSongViewController alloc] init];
    [like setTitle:@"我喜爱的"];
    PodcastsViewController *podcasts = [[PodcastsViewController alloc] init];
    [podcasts setTitle:@"播客"];
    LibrarySongViewController *song = [[LibrarySongViewController alloc] init];
    [song setTitle:@"本地音乐"];

    _lists =@[like,song,podcasts,]; //@[like,album,song,playlist,podcasts];
    mainDispatch(^{
        completion();
    });
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _lists.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_identifier];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    if ([_delegate respondsToSelector:@selector(configureCell:object:)]) {
        [_delegate configureCell:cell object:[_lists objectAtIndex:indexPath.row]];
    }
    return cell;
}
@end
