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
#import "DetailViewController.h"
#import "PersonalizedRequestFactory.h"

#import "LibraryPlaylist.h"
#import "Resource.h"
@interface MyMusicViewController ()
//local
@property(nonatomic, strong) NSArray<MPMediaItem*>  *items;

//lib playlists
@property(nonatomic, strong) NSArray<Resource*> *playlistsResources;

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
            NSArray *items = [[MPMediaQuery songsQuery] items];
            self.items = items;
            [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
        }
    }];

    //注册Cell
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:reuseId];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    if (section == 1) {
        return self.playlistsResources.count;
    }
    return 0;
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
    if (indexPath.section == 1) {
        Resource *resource = [self.playlistsResources objectAtIndex:indexPath.row];
        [cell.textLabel setText:[resource.attributes valueForKey:@"name"]];
    }
    [cell.textLabel setTextColor:MainColor];

    return cell;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"本地音乐";
    }
    if (section == 1) {
        return @"创建的列表";
    }
    return @"";
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 22.0f;
}

#pragma mark - Table View Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0 && indexPath.section == 0) {
        LocalMusicViewController *lmCtr = [[LocalMusicViewController alloc] initWithStyle:UITableViewStylePlain];
        [self.navigationController pushViewController:lmCtr animated:YES];
    }
    if (indexPath.section == 1) {
        Resource *resource = [self.playlistsResources objectAtIndex:indexPath.row];
        DetailViewController *detail = [[DetailViewController alloc] initWithResource:resource];
        [self.navigationController pushViewController:detail animated:YES];
    }
}

#pragma mark - 请求所有播放列表
-(void) requestAllLibraryPlaylist{
    NSURLRequest *request = [[PersonalizedRequestFactory new] fetchLibraryResourceWithType:LibraryResourcePlaylists fromIds:@[]];
    [self dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *json = [self serializationDataWithResponse:response data:data error:error];
        NSMutableArray<Resource*> *resources = [NSMutableArray array];
        for (NSDictionary *dict in [json valueForKey:@"data"]) {
            [resources addObject:[Resource instanceWithDict:dict]];
        }
        self.playlistsResources = resources;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}

@end
