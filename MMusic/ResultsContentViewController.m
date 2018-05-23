//
//  ResultsContentViewController.m
//  MMusic
//
//  Created by Magician on 2018/5/22.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <MJRefresh.h>

#import "ResultsContentViewController.h"
#import "ResultsContentCell.h"

#import "RequestFactory.h"

#import "ResponseRoot.h"
#import "Resource.h"

@interface ResultsContentViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic, strong) UITableView *tableView;
@end

static NSString *const cellID = @"tableCellReuseID";

@implementation ResultsContentViewController

- (instancetype)initWithResponseRoot:(ResponseRoot *)responseRoot{
    if (self = [super init]) {
        _responseRoot = responseRoot;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.view = self.tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.responseRoot.data.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ResultsContentCell *cell = (ResultsContentCell*)[tableView dequeueReusableCellWithIdentifier:cellID];
    Resource *resource = [self.responseRoot.data objectAtIndex:indexPath.row];
    cell.nameLabel.text = [resource.attributes valueForKey:@"name"];

    if ([resource.attributes valueForKey:@"artistName"]) {
        cell.artistLabel.text = [resource.attributes valueForKey:@"artistName"];
    }
    if ([resource.attributes valueForKey:@""] || [resource.attributes valueForKey:@""]) {
        
    }

    return cell;
}
#pragma mark - UITableViewDelegate
/**
 -(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
 ResponseRoot *root = [[self.results objectAtIndex:indexPath.section] allValues].firstObject;
 Resource *resource = [root.data objectAtIndex:indexPath.row];

 //确定操作 专辑和播放列表弹出详细视图  其他直接播放
 NSString *type = resource.type;

 // album  / playlist
 if ([type isEqualToString:@"albums"] || [type isEqualToString:@"playlists"]) {
 DetailViewController *detail = [[DetailViewController alloc] initWithResource:resource];
 [self.navigationController pushViewController:detail animated:YES];
 }

 //mv
 if ([type isEqualToString:@"music-videos"]) {
 MusicVideo *mv = [MusicVideo instanceWithDict:resource.attributes];
 [self openToPlayQueueDescriptor:[self playParametersQueueDescriptorFromParams:@[mv.playParams,] startAtIndexPath:indexPath]];
 }

 //song / station
 if ([type isEqualToString:@"songs"] || [type isEqualToString:@"stations"]) {
 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
 NSDictionary *dict = [resource.attributes valueForKeyPath:@"playParams"];
 MPMusicPlayerController *playCtr =[MPMusicPlayerController systemMusicPlayer];
 [playCtr setQueueWithDescriptor:[self playParametersQueueDescriptorFromParams:@[dict,] startAtIndexPath:indexPath]];
 [playCtr play];
 });
 }
 }

 #pragma mark - MPSystemMusicPlayerController
 - (void)openToPlayQueueDescriptor:(MPMusicPlayerQueueDescriptor *)queueDescriptor{
 UIApplication *app = [UIApplication sharedApplication];
 NSURL *url = [NSURL URLWithString:@"Music:prefs:root=MUSIC"];
 if ([app canOpenURL:url]) {
 [app openURL:url options:@{} completionHandler:^(BOOL success) {
 [[MPMusicPlayerController systemMusicPlayer] setQueueWithDescriptor:queueDescriptor];
 [[MPMusicPlayerController systemMusicPlayer] play];
 }];
 }
 }

 */

#pragma mark - getter
-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;

        [_tableView registerClass:ResultsContentCell.class forCellReuseIdentifier:cellID];

        //[self registerCellForTableView:_tableView];

        //刷新  初始有下一页 , 设置刷新控件
        if (self.responseRoot.next) {
            _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                if (self.responseRoot.next) {
                    [self loadNextPageWithHref:self.responseRoot.next];
                }else{
                    [self->_tableView.mj_footer endRefreshingWithNoMoreData];
                }
            }];
        }
    }
    return _tableView;
}


#pragma mark - helper
//-(void) registerCellForTableView:(UITableView*) tableViwe{
//    //activities, artists, apple-curators, albums, curators, songs, playlists, music-videos, and stations.
//    Resource *resource = self.responseRoot.data.firstObject;
//    NSString *type = resource.type;
//    if ([type isEqualToString:@"activities"]) {
//
//    }
//    if ([type isEqualToString:@"artists"]) {
//
//    }
//    if ([type isEqualToString:@"apple-curators"]) {
//
//    }
//    if ([type isEqualToString:@"albums"]) {
//
//    }
//    if ([type isEqualToString:@"curators"]) {
//
//    }
//    if ([type isEqualToString:@"songs"]) {
//        tableViwe registerClass:<#(nullable Class)#> forCellReuseIdentifier:cellID
//    }
//    if ([type isEqualToString:@"playlists"]) {
//
//    }
//    if ([type isEqualToString:@"music-videos"]) {
//
//    }
//    if ([type isEqualToString:@"stations"]) {
//
//    }
//}


-(void) loadNextPageWithHref:(NSString*) href{
    NSURLRequest *request = [[RequestFactory new] createRequestWithHref:href];
    [self dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *json = [self serializationDataWithResponse:response data:data error:nil];
        if (json) {
            json = [json objectForKey:@"results"];
            //枚举当前的 josn
            [json enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                ResponseRoot *newRoot = [ResponseRoot instanceWithDict:obj];
                //添加 到原有的数据列表中
                if (newRoot.next) {
                    self.responseRoot.next = newRoot.next;
                }else{
                    self.responseRoot.next = nil;
                }
                self.responseRoot.data = [self.responseRoot.data arrayByAddingObjectsFromArray:newRoot.data];

                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView.mj_footer endRefreshing];
                    [self.tableView reloadData];
                });
            }];
        }
    }];
}


@end
