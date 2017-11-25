//
//  LocalMusicViewController.m
//  MMusic
//
//  Created by Magician on 2017/11/6.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "LocalMusicViewController.h"
#import "LocalMusicViewCell.h"
#import <MediaPlayer/MediaPlayer.h>
#import <StoreKit/StoreKit.h>

@interface LocalMusicViewController ()
@property(nonatomic, strong) NSArray<MPMediaItem*>  *items;
@property(nonatomic, strong) MPMediaQuery  *query;
@property(nonatomic, strong) MPMediaItem  *nowPlayerItem;

@end

static NSString *reuseID = @"localMusicCellIdentifier";
@implementation LocalMusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"本地音乐"];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.

    self.navigationItem.rightBarButtonItem = self.editButtonItem;

    [self.tableView registerClass:[LocalMusicViewCell class] forCellReuseIdentifier:reuseID];

    //读取本地音乐数据
    [SKCloudServiceController requestAuthorization:^(SKCloudServiceAuthorizationStatus status) {
        if (status == SKCloudServiceAuthorizationStatusAuthorized) {
            self.query = [MPMediaQuery songsQuery];
            self.items = [self.query items];

            //刷新数据
            [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
        }
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID forIndexPath:indexPath];
    MPMediaItem *item = [self.items objectAtIndex:indexPath.row];
    [cell.textLabel setText:item.title];
    return cell;
}

#pragma makr table View delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MPMusicPlayerController *player = [MPMusicPlayerController systemMusicPlayer];
    MPMediaItem *item = [self.items objectAtIndex:indexPath.row];
    [player setQueueWithQuery:self.query];
    [player setNowPlayingItem:item];
    if (player.playbackState == MPMusicPlaybackStatePlaying && self.nowPlayerItem == player.nowPlayingItem) {
        [player pause];
        return;
    }
    self.nowPlayerItem = item;
    [player play];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



@end
