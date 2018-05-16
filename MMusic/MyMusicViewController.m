//
//  MyMusicViewController.m
//  MMusic
//
//  Created by Magician on 2017/11/8.
//  Copyright © 2017年 com.😈. All rights reserved.
//
#import <MediaPlayer/MediaPlayer.h>
#import <StoreKit/StoreKit.h>

#import "MyMusicViewController.h"
#import "LocalMusicViewController.h"
#import "PersonalizedRequestFactory.h"

#import "LibraryPlaylist.h"
@interface MyMusicViewController ()
//local
@property(nonatomic, strong) NSArray<MPMediaItem*>  *items;

//playlist
@property(nonatomic, strong) NSArray<LibraryPlaylist*> *playlists;

@end

static NSString *reuseId = @"MyMusicViewControllerCellId";
@implementation MyMusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"我的音乐"];

    [self requestAllLibraryPlaylist];
    //读取本地音乐数据
    [SKCloudServiceController requestAuthorization:^(SKCloudServiceAuthorizationStatus status) {
        if (status == SKCloudServiceAuthorizationStatusAuthorized) {
            self.items = [[MPMediaQuery songsQuery] items];
            [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
        }
    }];

    //注册Cell
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:reuseId];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
     self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.playlists.count+1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId forIndexPath:indexPath];
    if (indexPath.row == 0 && indexPath.section == 0) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseId];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        NSString *detailStr = [NSString stringWithFormat:@"%ld",self.items.count];
        [cell.detailTextLabel setText:detailStr];
        [cell.textLabel setText:@"本地音乐"];
    }
    if (indexPath.row == 1) {
        NSUInteger index = indexPath.row;
        LibraryPlaylist *playlist = [self.playlists objectAtIndex:--index];
        cell.textLabel.text = playlist.name;
    
    }

    return cell;
}

#pragma mark - Table View Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0 && indexPath.section == 0) {
        LocalMusicViewController *lmCtr = [[LocalMusicViewController alloc] initWithStyle:UITableViewStylePlain];
        [self.navigationController pushViewController:lmCtr animated:YES];
    }

    if (indexPath.row == 1) {
        NSUInteger index = indexPath.row;
        LibraryPlaylist *playlist = [self.playlists objectAtIndex:--index];

    }
}

#pragma mark - 请求所有播放列表
-(void) requestAllLibraryPlaylist{
    
}


@end
