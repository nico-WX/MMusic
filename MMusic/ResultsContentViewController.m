//
//  ResultsContentViewController.m
//  MMusic
//
//  Created by Magician on 2018/5/22.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <Masonry.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MJRefresh.h>

#import "ResultsContentViewController.h"
#import "DetailViewController.h"
#import "ArtistsViewController.h"
#import "ResultsCell.h"
#import "ResultsArtistsCell.h"
#import "ResultsMusicVideoCell.h"

#import "CuratorsAndActivitiesViewController.h"

#import "RequestFactory.h"

#import "ResponseRoot.h"
#import "Resource.h"
#import "Artwork.h"

@interface ResultsContentViewController ()<UITableViewDelegate,UITableViewDataSource,MPSystemMusicPlayerController>

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

    //直接替换self.view  会出现TableView 部分cell 没有separator 线?
    [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    //填充父视图
    UIView *superview = self.view;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(superview).insets(UIEdgeInsetsZero);
    }];
}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.responseRoot.data.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    ResultsCell *cell = (ResultsCell*)[tableView dequeueReusableCellWithIdentifier:cellID];
    Resource *resource = [self.responseRoot.data objectAtIndex:indexPath.row];
    cell.resource = resource;
    return cell;
}
#pragma mark - UITableViewDelegate
 -(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

     Resource *resource = [self.responseRoot.data objectAtIndex:indexPath.row];

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
         for (Resource *res in _responseRoot.data) {
             [list addObject: [res.attributes valueForKey:@"playParams"]];
         }
         [self openToPlayQueueDescriptor:[self playParametersQueueFromParams:list startAtIndexPath:indexPath]];
     }

     //song / station 直接播放
     if ([type isEqualToString:@"songs"] || [type isEqualToString:@"stations"]) {
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
             NSMutableArray *list = [NSMutableArray array];
             for (Resource *res in self->_responseRoot.data) {
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
     if ([type isEqualToString:@"curators"] || [type isEqualToString:@"apple-curators"] || [type isEqualToString:@"activities"]) {
         CuratorsAndActivitiesViewController *vc = [[CuratorsAndActivitiesViewController alloc] initWithResource:resource];
         [self.navigationController pushViewController:vc animated:YES];
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

#pragma mark - getter
-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView setRowHeight:66];

        //cell type
        NSString *type = self.responseRoot.data.lastObject.type;
        if ([type isEqualToString:@"artists"]) {
            [_tableView registerClass:ResultsArtistsCell.class forCellReuseIdentifier:cellID];
        }else if ([type isEqualToString:@"music-videos"]){
            [_tableView registerClass:ResultsMusicVideoCell.class forCellReuseIdentifier:cellID];
        }else{
            [_tableView registerClass:ResultsCell.class forCellReuseIdentifier:cellID];
        }

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

-(void) loadNextPageWithHref:(NSString*) href{
    NSURLRequest *request = [[RequestFactory new] createRequestWithHref:href];
    [self dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *json = [self serializationDataWithResponse:response data:data error:nil];

        json = [json objectForKey:@"results"];
        if (json.allKeys.count >0) {
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
            }];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView.mj_footer endRefreshing];
                [self.tableView reloadData];
            });
        }else{
            self.responseRoot.next = nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            });
        }
    }];
}


@end
