//
//  MMBottomTableViewController.m
//  MMusic
//
//  Created by Magician on 2017/12/7.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

#import "MMBottomTableViewController.h"
#import "MMBottomTableViewCell.h"

#import "RequestFactory.h"
#import "PersonalizedRequestFactory.h"
#import "NSObject+Tool.h"
#import "MMPlayerController.h"

#import "Song.h"

@interface MMBottomTableViewController ()
@property(nonatomic, strong) NSArray<Song*> *songs;
@property(nonatomic, strong) MPMusicPlayerPlayParametersQueueDescriptor *queueDes;
@property(nonatomic,strong) NSArray<MPMusicPlayerPlayParameters *> *paramters;

@property(nonatomic, strong) MMPlayerController *playerCtr;//**播放器控制器
@end

static NSString *cellReuseIdentifier = @"reuseIdentifier";
@implementation MMBottomTableViewController
- (void)viewDidLoad {
    [super viewDidLoad];

    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.tableView registerClass:[MMBottomTableViewCell class] forCellReuseIdentifier:cellReuseIdentifier];
    self.playerCtr = [MMPlayerController sharePlayerController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/**设置Resource 时发请求Song数据*/
-(void)setResource:(Resource *)resource{
    if (_resource != resource) {
        _resource = resource;
        [self requestDataWithResource:_resource];
    }
}
- (void)setSongs:(NSArray<Song *> *)songs{
    if (_songs != songs) {
        _songs = songs;
        _queueDes = nil;
    }
}
#pragma mark layz
-(MPMusicPlayerPlayParametersQueueDescriptor *)queueDes{
    if (!_queueDes) {
        NSMutableArray *temp = [NSMutableArray array];
        for (Song *song in _songs) {
            MPMusicPlayerPlayParameters *p;
            p = [[MPMusicPlayerPlayParameters alloc] initWithDictionary:song.playParams];

            [temp addObject:p];
        }
        Log(@"<<<<<<<< %@",temp);
        _paramters = temp;
        _queueDes = [[MPMusicPlayerPlayParametersQueueDescriptor alloc] initWithPlayParametersQueue:_paramters];
    }
    return _queueDes;
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.songs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MMBottomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier forIndexPath:indexPath];
    cell.song = nil;    //清空旧数据
    if (self.songs) {
        Song *song = [self.songs objectAtIndex:indexPath.row];
        cell.song = song;
    }
    return cell;
}

//通过Resource Id 请求对应的数据
- (void)requestDataWithResource:(Resource *) resource{
    NSURLRequest *request = [[RequestFactory requestFactory] createRequestWithHerf:resource.href];
    [self dataTaskWithdRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *dict = [self serializationDataWithResponse:response data:data error:error];
#warning serialization is no good
        dict = [[[[dict objectForKey:@"data"] firstObject] objectForKey:@"relationships"] objectForKey:@"tracks"];
        NSArray *temp = [dict objectForKey:@"data"];
        NSMutableArray *tempSongs = [NSMutableArray array];
        for (dict in temp) {
            Song *song;
            if ([dict objectForKey:@"attributes"]) {
                song = [Song instanceWithDict:[dict objectForKey:@"attributes"]];
                [tempSongs addObject:song];
            }
        }
        self.songs = tempSongs;
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [self.queueDes setStartItemPlayParameters:[self.paramters objectAtIndex:indexPath.row]];
    [self.playerCtr.player setQueueWithDescriptor:self.queueDes];
    [self.playerCtr.player play];

}


@end
