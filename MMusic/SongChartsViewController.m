//
//  SongChartsViewController.m
//  MMusic
//
//  Created by Magician on 2018/4/2.
//  Copyright © 2018年 com.😈. All rights reserved.
//
#import <MediaPlayer/MediaPlayer.h>
#import <Masonry.h>
#import <MJRefresh.h>

#import "SongChartsViewController.h"
#import "ChartsSongCell.h"
#import "NewCardView.h"
#import "PlayerViewController.h"

#import "RequestFactory.h"
#import "Artwork.h"
#import "Song.h"

@interface SongChartsViewController ()<UITableViewDelegate, UITableViewDataSource>
@property(nonatomic, strong) NewCardView *cardView;
@property(nonatomic, strong) NSArray<Song*> *songList;
@property(nonatomic, strong) NSString *next;
@property(nonatomic, strong) UITableView *tableView;

@property(nonatomic, strong) PlayerViewController *playerVC;
//播放参数列表
@property(nonatomic, strong) NSArray<MPMusicPlayerPlayParameters*> *playParametersList;
//播放参数队列
@property(nonatomic, strong) MPMusicPlayerPlayParametersQueueDescriptor *queueDesc;
@end

@implementation SongChartsViewController

static NSString *const reuseIdentifier = @"ChartsSongCell";
- (void)viewDidLoad {
    [super viewDidLoad];

    [self requeData];

    self.cardView = ({
        NewCardView *view = [[NewCardView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:view];

        view;
    });

    self.tableView = ({
        UITableView *tableview = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [tableview registerClass:[ChartsSongCell class] forCellReuseIdentifier:reuseIdentifier];
        tableview.layer.cornerRadius = 8.0f;
        tableview.layer.masksToBounds = YES;
        tableview.delegate = self;
        tableview.dataSource = self;
        tableview.separatorColor = UIColor.whiteColor;
        tableview.backgroundColor = self.cardView.contentView.backgroundColor;
        tableview;
    });

    //添加tableView 到卡片视图
    [self.cardView.contentView addSubview:self.tableView];

    //布局
    ({
        //导航栏状态栏 tabBar 高度
        CGFloat statusH = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
        CGFloat navH = CGRectGetHeight(self.navigationController.navigationBar.frame);
        CGFloat tabH = 0.0f; // CGRectGetHeight(self.tabBarController.tabBar.frame);
                             //边距
        UIEdgeInsets padding = UIEdgeInsetsMake((statusH+navH+4), 4, (tabH+0), 4);
        //layout cardView
        UIView *superview = self.view;
        [self.cardView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(superview.mas_top).with.offset(padding.top);
            make.left.mas_equalTo(superview.mas_left).with.offset(padding.left);
            make.right.mas_equalTo(superview.mas_right).with.offset(-padding.right);
            make.bottom.mas_equalTo(superview.mas_bottom).with.offset(-padding.bottom);
        }];

        superview = self.cardView.contentView;
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            UIEdgeInsets padding = UIEdgeInsetsMake(0, 4, 4, 4);
            make.edges.mas_equalTo(superview).with.insets(padding);
        }];
    });

    __weak typeof(self) weakSelf = self;
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        if (weakSelf.next) {
            [weakSelf loadNextPage];
        }else{
            [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
        }
    }];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        weakSelf.songList = nil;
        [weakSelf requeData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark 请求数据 及解析JSON  加载分页数据
-(void) requeData{
    NSURLRequest *request = [[RequestFactory requestFactory] createChartWithChartType:ChartSongsType];
    [self dataTaskWithdRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSDictionary *json = [self serializationDataWithResponse:response data:data error:error];
            if (json) {
                self.songList = [self serializationDict:json];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    [self.tableView.mj_header endRefreshing];
                });
            }
        }
    }];
}

/**加载下一页数据*/
-(void) loadNextPage{
    if (self.next) {
        NSURLRequest *request = [[RequestFactory requestFactory] createRequestWithHerf:self.next];
        [self dataTaskWithdRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (!error && data) {
                NSDictionary *json =  [self serializationDataWithResponse:response data:data error:error];
                if (json) {
                    self.songList= [self.songList arrayByAddingObjectsFromArray:[self serializationDict:json]];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                        [self.tableView.mj_footer endRefreshing];
                    });
                }
            }
        }];
    }
}

/**解析返回的JSON 到对象模型中*/
- (NSArray<Song*> *)serializationDict:(NSDictionary*) json{
    json = [json objectForKey:@"results"];

    NSMutableArray<Song*> *songArray = NSMutableArray.new;
    NSMutableArray<MPMusicPlayerPlayParameters*> *parArray = NSMutableArray.new;
    for (NSDictionary *subJSON in [json objectForKey:@"songs"] ) {
        for (NSDictionary *songDict in [subJSON objectForKey:@"data"]) {
            Song *song = [Song instanceWithDict:[songDict objectForKey:@"attributes"]];
            [songArray addObject:song];
            [parArray addObject:[[MPMusicPlayerPlayParameters alloc] initWithDictionary:song.playParams]];
        }
        //记录分页
        NSString *page = [subJSON objectForKey:@"next"];
        self.next = page ? page : nil;

        //设置title
        dispatch_async(dispatch_get_main_queue(), ^{
            self.cardView.titleLabel.text = [subJSON objectForKey:@"name"];
        });

        self.playParametersList = self.playParametersList == NULL ? parArray : [self.playParametersList arrayByAddingObjectsFromArray:parArray];
        self.queueDesc = [[MPMusicPlayerPlayParametersQueueDescriptor alloc]  initWithPlayParametersQueue:self.playParametersList];
    }
    return songArray;
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.songList.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChartsSongCell *cell = (ChartsSongCell*)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];

     //Configure the cell...
    Song *song = [self.songList objectAtIndex:indexPath.row];
    cell.nameLabel.text = song.name;
    cell.artistLabel.text = song.artistName;

    Artwork *art = song.artwork;
    [self showImageToView:cell.artworkView withImageURL:art.url cacheToMemory:YES];

    cell.backgroundColor = self.cardView.contentView.backgroundColor;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.0f;
}

#pragma mark UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.playerVC = [PlayerViewController sharePlayerViewController];

    Song *selectSong = [self.songList objectAtIndex:indexPath.row];
    NSString *nowPlayItemId = self.playerVC.playerController.nowPlayingItem.playbackStoreID;
    NSString *selectSongId = [selectSong.playParams objectForKey:@"id"];
    if (![nowPlayItemId isEqualToString:selectSongId]) {
        [self.queueDesc setStartItemPlayParameters:[self.playParametersList objectAtIndex:indexPath.row]];
        [self.playerVC.playerController setQueueWithDescriptor:self.queueDesc];
        [self.playerVC.playerController prepareToPlay];
    }

    [self.playerVC showFromViewController:self withSongList:self.songList andStarItem:[self.songList objectAtIndex:indexPath.row]];
}

@end
