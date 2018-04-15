//
//  ResultsViewController.m
//  MMusic
//
//  Created by Magician on 2018/4/9.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <Masonry.h>
#import "ResultsViewController.h"

#import "RequestFactory.h"
#import "Artist.h"
#import "Activity.h"
#import "AppleCurator.h"
#import "Album.h"
#import "Curator.h"
#import "Song.h"
#import "Playlist.h"
#import "MusicVideo.h"
#import "Station.h"

@interface ResultsViewController ()<UITableViewDelegate, UITableViewDataSource>
@property(nonatomic, strong) Artist *artist;
@property(nonatomic, strong) UITableView *tableView;

//
@property(nonatomic, strong) NSArray<NSArray*> *allSearchDatas;
@property(nonatomic, strong) NSArray<NSString*> *titles;
@end

@implementation ResultsViewController

static NSString *const cellIdentifier = @"cellReuseIdentifier";
- (instancetype)initWithArtist:(Artist *)artist{
    if (self = [super init]) {
        self.artist = artist;
        self.title = artist.name;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;

    self.tableView = ({
        UITableView *view = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [view registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
        view.delegate = self;
        view.dataSource = self;
        [self.view addSubview:view];

        view;
    });

    CGFloat navH = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    CGFloat tabH = CGRectGetHeight(self.tabBarController.tabBar.frame);
    //layout
    UIEdgeInsets padding = UIEdgeInsetsMake(navH, 0, tabH, 0);
    UIView *superview = self.view;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superview.mas_top).with.offset(padding.top);
        make.left.mas_equalTo(superview.mas_left);
        make.right.mas_equalTo(superview.mas_right);
        make.bottom.mas_equalTo(superview.mas_bottom).with.offset(-padding.bottom);
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) requestDataWithArtistName:(NSString *) name{
    NSURLRequest *request = [[RequestFactory requestFactory] createSearchWithText:name];

    [self dataTaskWithdRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error && data) {
            NSDictionary *json = [self serializationDataWithResponse:response data:data error:error];
            [self serializatonJSON:json];
        }
    }];
}

-(void) serializatonJSON:(NSDictionary*) json{
    json = [json objectForKey:@"results"];
    NSMutableArray *tempAll = NSMutableArray.new;   //所有数据
    NSMutableArray *sectionTitle = NSMutableArray.new;  //节title

    //返回的JSON 不确定内容 使用枚举器
    for ( NSEnumerator *rator in [json keyEnumerator]) {
        [sectionTitle addObject:(NSString*)rator];
        NSDictionary *subJSON = [json objectForKey:rator];
        NSMutableArray *tempSection = NSMutableArray.new;
        for (NSDictionary *dict in [subJSON objectForKey:@"data"]) {
            //activities, artists, apple-curators, albums, curators, songs, playlists, music-videos,  stations.
            Class cls =  [self classForResourceType:[dict objectForKey:@"type"]];
            [tempSection addObject:[cls instanceWithDict:[dict objectForKey:@"attributes"]]];
        }
        [tempAll addObject:tempSection];
    }
    self.allSearchDatas = tempAll;
    self.titles = sectionTitle;
    //刷新
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    //Log(@"all=%@",tempAll);
}

-(Class) classForResourceType:(NSString*)type{
    Class cls;
    if ([type isEqualToString:@"activities"])       cls = Activity.class;
    if ([type isEqualToString:@"artists"])          cls = Artist.class;
    if ([type isEqualToString:@"apple-curators"])   cls = AppleCurator.class;
    if ([type isEqualToString:@"albums"])           cls = Album.class;
    if ([type isEqualToString:@"curators"])         cls = Curator.class;
    if ([type isEqualToString:@"songs"])            cls = Song.class;
    if ([type isEqualToString:@"playlists"])        cls = Playlist.class;
    if ([type isEqualToString:@"music-videos"])     cls = MusicVideo.class;
    if ([type isEqualToString:@"stations"])         cls = Station.class;
    return cls;
}

#pragma mark UITableViewDelegate

#pragma mark UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    return cell;
}

@end
