//
//  TableViewController.m
//  MMusic
//
//  Created by Magician on 2018/5/29.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <MJRefresh.h>
#import <MediaPlayer/MediaPlayer.h>

#import "TableViewController.h"
#import "ResultsArtistsCell.h"
#import "ResultsMusicVideoCell.h"
#import "ResultsCell.h"

#import "PlayerViewController.h"
#import "DetailViewController.h"
#import "ArtistsViewController.h"

#import "ResponseRoot.h"
#import "Resource.h"

#import "RequestFactory.h"

@interface TableViewController ()<MPSystemMusicPlayerController>
@property(nonatomic, strong) UITableView *myTableView;
@property(nonatomic, strong, readonly) ResponseRoot *root;
@end

static NSString *const cellID = @"cellReuseIdentifier";
@implementation TableViewController

-(instancetype)initWithStyle:(UITableViewStyle)style forResponseRoot:(ResponseRoot *)responseRoot{
    if (self = [super initWithStyle:style]) {
        _root = responseRoot;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    //替换TableView
    self.tableView = self.myTableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.root.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ResultsCell *cell = (ResultsCell*)[tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    Resource *resource = [self.root.data objectAtIndex:indexPath.row];
    cell.resource = resource;
    return cell;
}

#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    Resource *resource = [self.root.data objectAtIndex:indexPath.row];

    // 可能的资源类型: activities, artists, apple-curators, albums, curators, songs, playlists, music-videos,stations.

    //判断不同的资源类型, 区别操作
    NSString *type = resource.type;

    // album  / playlist  弹出详细页面
    if ([type isEqualToString:@"albums"] || [type isEqualToString:@"playlists"]) {
        DetailViewController *detail = [[DetailViewController alloc] initWithResource:resource];
        [self.navigationController pushViewController:detail animated:YES];
    }

    //mv 跳转到Music App 播放
    if ([type isEqualToString:@"music-videos"]) {
        NSMutableArray *list = [NSMutableArray array];
        for (Resource *res in self.root.data) {
            [list addObject: [res.attributes valueForKey:@"playParams"]];
        }
        [self openToPlayQueueDescriptor:[self playParametersQueueFromParams:list startAtIndexPath:indexPath]];
    }

    //song / station 直接播放
    if ([type isEqualToString:@"songs"] || [type isEqualToString:@"stations"]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableArray *list = [NSMutableArray array];
            for (Resource *res in self.root.data) {
                [list addObject: [res.attributes valueForKey:@"playParams"]];
            }

            MPMusicPlayerController *playCtr =[MPMusicPlayerController systemMusicPlayer];
            [playCtr setQueueWithDescriptor:[self playParametersQueueFromParams:list startAtIndexPath:indexPath]];
            [playCtr play];
        });
    }
    //artists 显示艺人详情页
    if ([type isEqualToString:@"artists"]) {
        ArtistsViewController *artist = [[ArtistsViewController alloc] initWithArtistsName:[resource.attributes valueForKey:@"name"]];
        [self.navigationController pushViewController:artist animated:YES];
    }

    //curators  / apple-curators  /activities

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

#pragma mark - Helper
-(void) loadNextPageWithHref:(NSString *) href{
    NSURLRequest *request = [[RequestFactory new] createRequestWithHref:href];
    [self dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *json = [self serializationDataWithResponse:response data:data error:nil];

        json = [json objectForKey:@"results"];
        if (json.allKeys.count >0) {    //如果返回结果为空的字典, 说明已经没有更多数据了.

            //枚举当前的 josn
            [json enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                ResponseRoot *newRoot = [ResponseRoot instanceWithDict:obj];
                //添加 到原有的数据列表中
                if (newRoot.next) {
                    self.root.next = newRoot.next;
                }else{
                    self.root.next = nil;
                }
                self.root.data = [self.root.data arrayByAddingObjectsFromArray:newRoot.data];
            }];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView.mj_footer endRefreshing];
                [self.tableView reloadData];
            });
        }else{
            self.root.next = nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            });
        }
    }];
}

#pragma mark - getter
-(UITableView *)myTableView{
    if (!_myTableView) {

        _myTableView = [[UITableView alloc] initWithFrame:self.tableView.frame style:UITableViewStylePlain];
        [_myTableView setDataSource:self];
        [_myTableView setDelegate:self];
        [_myTableView setRowHeight:66.0f];

        //分别注册cell
        //cell type
        NSString *type = self.root.data.lastObject.type;
        if ([type isEqualToString:@"artists"]) {
            [_myTableView registerClass:ResultsArtistsCell.class forCellReuseIdentifier:cellID];
        }else if ([type isEqualToString:@"music-videos"]){
            [_myTableView registerClass:ResultsMusicVideoCell.class forCellReuseIdentifier:cellID];
        }else{
            [_myTableView registerClass:ResultsCell.class forCellReuseIdentifier:cellID];
        }

        //刷新  初始有下一页 , 设置刷新控件
        if (self.root.next) {
            _myTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                if (self.root.next) {
                    [self loadNextPageWithHref:self.root.next];
                }else{
                    [self->_myTableView.mj_footer endRefreshingWithNoMoreData];
                }
            }];
        }
    }

    return _myTableView;
}
@end
