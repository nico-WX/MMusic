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
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPlaylists)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)addPlaylists{
    UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:@"新建播放列表" message:@"" preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertCtr addAction:action];
    

    [alertCtr addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"输入播放列表名称";
    }];

    [self presentViewController:alertCtr animated:YES completion:nil];
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
        LocalMusicViewController *lmCtr = [[LocalMusicViewController alloc] init];
        [self.navigationController pushViewController:lmCtr animated:YES];
    }
    if (indexPath.section == 1) {
    }
}

#pragma mark - 请求所有播放列表
-(void) requestAllLibraryPlaylist{
    [MusicKit.new.library resource:@[] byType:CLibraryPlaylists callBack:^(NSDictionary *json, NSHTTPURLResponse *response) {
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
