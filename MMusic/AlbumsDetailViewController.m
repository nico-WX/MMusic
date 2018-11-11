//
//  AlbumsDetailViewController.m
//  MMusic
//
//  Created by Magician on 2018/5/29.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import <Masonry.h>

#import "AlbumsDetailViewController.h"
#import "AlbumsSongCell.h"
#import "DetailHeaderView.h"

#import "Album.h"
#import "Song.h"
#import "Artwork.h"

#import "MusicKit.h"
//#import "RequestFactory.h"

@interface AlbumsDetailViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, strong, readonly) Album    *album;
@property(nonatomic, strong) NSArray<Song*>     *songs;
@property(nonatomic, strong) DetailHeaderView   *headerView;
@property(nonatomic, strong) UITableView        *tableView;
@property(nonatomic, strong) MPMusicPlayerPlayParametersQueueDescriptor *playQueue;
@end

static NSString *const cellID = @"cellReuseIDentifier";
@implementation AlbumsDetailViewController

-(instancetype)initWithAlbum:(Album *)album{
    if (self = [super init]) {
        _album = album;
    }
    return self;
}
#pragma mark -cycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self.headerView];
    [self.view addSubview:self.tableView];

    //设置头部信息
    [self.headerView.nameLabel setText:self.album.name];
    [self.headerView.desc setText:self.album.recordLabel];
    [self showImageToView:self.headerView.artworkView withImageURL:self.album.artwork.url cacheToMemory:NO];


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    __weak typeof(self) weakSelf = self;
    UIView *superview = self.view;

    //header 已经设置Frame
    //table
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.headerView.mas_bottom);
        make.left.mas_equalTo(superview.mas_left);
        make.right.mas_equalTo(superview.mas_right);

        CGFloat offset = CGRectGetHeight(weakSelf.tabBarController.tabBar.frame);
        make.bottom.mas_equalTo(superview.mas_bottom).offset(-offset);
    }];

}

#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.songs.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AlbumsSongCell *cell = (AlbumsSongCell*)[tableView dequeueReusableCellWithIdentifier:cellID];
    [cell.numberLabel setText:[NSString stringWithFormat:@"%2ld",indexPath.row]];
    [cell setSong:[self.songs objectAtIndex:indexPath.row]];
    return cell;
}
#pragma mark - UITableViewDelegate

#pragma mark - Helper
/**请求数据*/
- (void) requestData{
    NSString *identifier = [self.album.playParams valueForKey:@"id"];

    [[MusicKit new].catalog resources:@[identifier,] byType:CatalogAlbums callBack:^(NSDictionary *json, NSHTTPURLResponse *response) {
        self.songs = [self serializationJSON:json];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}
/**解析返回的JSON 数据*/
- (NSArray<Song*>*) serializationJSON:(NSDictionary*)json{
    NSMutableArray<Song*> *songList = [NSMutableArray array];
    NSMutableArray<MPMusicPlayerPlayParameters*> *playParameters = [NSMutableArray array];

    for (NSDictionary *temp in [json objectForKey:@"data"]) {
        NSArray *tracks = [temp valueForKeyPath:@"relationships.tracks.data"];
        for (NSDictionary *songDict in tracks) {
            Song *song = [Song instanceWithDict:[songDict objectForKey:@"attributes"]];
            [songList addObject:song];

            //获取播放参数
            [playParameters addObject:[[MPMusicPlayerPlayParameters alloc] initWithDictionary:song.playParams]];
        }
    }
    //设置播放队列
    self.playQueue = [[MPMusicPlayerPlayParametersQueueDescriptor alloc] initWithPlayParametersQueue:playParameters];
    return songList;
}


#pragma mark - getter
-(DetailHeaderView *)headerView{
    if (!_headerView) {
        CGFloat y = CGRectGetHeight(self.navigationController.navigationBar.frame)+20;
        CGFloat w = CGRectGetWidth(self.view.frame);
        CGFloat h = 150;
        _headerView = [[DetailHeaderView alloc] initWithFrame:CGRectMake(0, y, w, h)];
    }
    return _headerView;
}

-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        [_tableView registerClass:AlbumsSongCell.class forCellReuseIdentifier:cellID];
    }
    return _tableView;
}

@end
