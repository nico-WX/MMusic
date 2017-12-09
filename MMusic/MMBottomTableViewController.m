//
//  MMBottomTableViewController.m
//  MMusic
//
//  Created by Magician on 2017/12/7.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "MMBottomTableViewController.h"
#import "RequestFactory.h"
#import "PersonalizedRequestFactory.h"
#import "NSObject+Serialization.h"
#import "MMPlayerController.h"
#import "Song.h"
#import "PlayParameters.h"
#import <MediaPlayer/MediaPlayer.h>

@interface MMBottomTableViewController ()
@property(nonatomic, strong) NSArray<Song*> *songs;
@property(nonatomic, strong) NSArray<NSDictionary*> *playParams;

/**播放器控制器*/
@property(nonatomic, strong) MMPlayerController *playerCtr;
@end

@implementation MMBottomTableViewController

static NSString *cellReuseIdentifier = @"reuseIdentifier";
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellReuseIdentifier];
    self.playerCtr = [MMPlayerController sharePlayerController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**设置Resource 时发请求Song数据*/
-(void)setResource:(Resource *)resource{
    if (_resource != resource) {
        _resource = resource;
    }
    [self requestDataWithResource:_resource];
}

#pragma mark layz
-(NSArray<NSDictionary *> *)playParams{
    if (!_playParams) {
        NSMutableArray *temp = [NSMutableArray array];
        for (Song *song in self.songs) {
            [temp addObject:song.playParams];
        }
        _playParams = temp;
    }
    return _playParams;
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
    if (self.songs) {
        return self.songs.count;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier forIndexPath:indexPath];
    if (self.songs) {
        Song *song = [self.songs objectAtIndex:indexPath.row];
        [cell.textLabel setText:song.name];
    }
    return cell;
}

//请求数据
- (void)requestDataWithResource:(Resource *) resource{
    RequestFactory *factory = [RequestFactory requestFactory];
    NSURLRequest *request = [factory createRequestWithHerf:resource.href];
    [self dataTaskWithdRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *dict = [self serializationDataWithResponse:response data:data error:error];
        dict = [[[[dict objectForKey:@"data"] firstObject] objectForKey:@"relationships"] objectForKey:@"tracks"];
        NSArray *temp = [dict objectForKey:@"data"];
        NSMutableArray *tempSongs = [NSMutableArray array];
        for (dict in temp) {
            Song *song = [Song instanceWithDict:[dict objectForKey:@"attributes"]];
            [tempSongs addObject:song];
        }
        self.songs = tempSongs;
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    }];
}

//封装发起任务请求操作
-(void)dataTaskWithdRequest:(NSURLRequest*) request completionHandler:(void(^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)) handler{
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        handler(data,response,error);
    }] resume];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{




    self.playerCtr.parameters = self.playParams;
    [self.playerCtr.player prepareToPlay];
    [self.playerCtr.player play];
    Log(@"%@",self.playerCtr.player.nowPlayingItem);
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
