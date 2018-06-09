//
//  ArtistsContentViewController.m
//  MMusic
//
//  Created by Magician on 2018/5/24.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <Masonry.h>
#import "ArtistsContentViewController.h"
#import "ArtistsContentTableView.h"
#import "ArtistsInfoView.h"
#import "SongCell.h"
#import "ResultsMusicVideoCell.h"
#import "ResultsCell.h"
#import "ResponseRoot.h"
#import "Resource.h"
#import "Song.h"


#import "PlayerViewController.h"

@interface ArtistsContentViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, strong) ArtistsContentTableView *tableView;
@property(nonatomic, strong) ArtistsInfoView *artistView;

@property(nonatomic, strong)NSArray<Song*> *songs;
@property(nonatomic, strong)NSArray<MusicVideo*> *musicVideos;
@end

static NSString *const cellID = @"cellReuseIdentifier";
@implementation ArtistsContentViewController

-(instancetype)initWithResponseRoot:(ResponseRoot *)responseRoot{
    if (self = [super init]) {
        _responseRoot = responseRoot;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    //不同的类型  添加不同的视图
    Resource *resource = self.responseRoot.data.lastObject ;
    if ([resource.type isEqualToString:@"artists"]) {
        Artist *artist = [Artist instanceWithDict:resource.attributes];
        [self.artistView setArtist:artist];
        [self.view addSubview:self.artistView];
        [self.artistView setBackgroundColor:UIColor.whiteColor];
    }else{
        [self.view addSubview:self.tableView];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    UIView *superview =self.view;
    Resource *resource = self.responseRoot.data.lastObject ;
    if ([resource.type isEqualToString:@"artists"]) {
        [self.artistView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(superview).insets(UIEdgeInsetsZero);
        }];
    }else{
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(superview).insets(UIEdgeInsetsZero) ;
        }];
    }
}


#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.responseRoot.data.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SongCell *cell = (SongCell*)[tableView dequeueReusableCellWithIdentifier:cellID];

    Resource *resource = [self.responseRoot.data objectAtIndex:indexPath.row];
    Song *song = [Song instanceWithDict:resource.attributes];
    cell.song = song;
    cell.numberLabel.text = [NSString stringWithFormat:@"%.2ld",indexPath.row+1];
    return cell;
}
#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    Resource *resource = [self.responseRoot.data objectAtIndex:indexPath.row];
    if ([resource.type isEqualToString:@"songs"]) {
        
    }
    if ([resource.type isEqualToString:@"albums"]) {

    }
    if ([resource.type isEqualToString:@"music-videos"]) {

    }
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    if (scrollView.contentOffset.y < 0) {
//        [self.tableView setScrollToTop:YES];
//    }else{
//        [self.tableView setScrollToTop:NO];
//    }

}


#pragma mark -getter
-(ArtistsContentTableView *)tableView{
    if (!_tableView) {
        _tableView = [[ArtistsContentTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView setShowsVerticalScrollIndicator:YES];
        [_tableView setRowHeight:44.0f];
        

        Resource *resource = self.responseRoot.data.firstObject;
        if ([resource.type isEqualToString:@"songs"]) {
            [_tableView registerClass:SongCell.class forCellReuseIdentifier:cellID];
        }
        if ([resource.type isEqualToString:@"albums"]) {
            [_tableView registerClass:ResultsCell.class forCellReuseIdentifier:cellID];
        }
        if ([resource.type isEqualToString:@"music-videos"]) {
            [_tableView registerClass:ResultsMusicVideoCell.class forCellReuseIdentifier:cellID];
        }



    }
    return _tableView;
}
- (ArtistsInfoView *)artistView{
    if (!_artistView) {
        _artistView = [[ArtistsInfoView alloc] initWithFrame:self.view.frame];
    }
    return _artistView;
}

@end
