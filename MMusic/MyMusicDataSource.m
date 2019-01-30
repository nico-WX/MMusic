//
//  MyMusicDataSource.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/27.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "MyMusicDataSource.h"
#import "MyLibraryContentViewController.h"

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
            dispatch_async(dispatch_get_main_queue(), ^{
                [tableView reloadData];
            });
        }];
    }
    return self;
}

- (void)loadDataWithCompletion:(void(^)(void))completion{
    //NSArray<NSString*> * temp = @[@"本地歌曲",@"我喜欢的",@"专辑",@"歌曲",@"播放列表",@"广播"];
    MyLibraryContentViewController *localSong   = [[MyLibraryContentViewController alloc] initWithType:LibraryLocalSongType];
    MyLibraryContentViewController *like        = [[MyLibraryContentViewController alloc] initWithType:LibraryMyLikeSongType];
    MyLibraryContentViewController *album       = [[MyLibraryContentViewController alloc] initWithType:LibraryAlbumType];
    MyLibraryContentViewController *song        = [[MyLibraryContentViewController alloc] initWithType:LibrarySongType];
    MyLibraryContentViewController *playlist    = [[MyLibraryContentViewController alloc] initWithType:LibraryPlaylistType];
    MyLibraryContentViewController *podcasts    = [[MyLibraryContentViewController alloc] initWithType:LibraryPodcastsType];

    _lists = @[localSong,like,album,song,playlist,podcasts];

    completion();
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
