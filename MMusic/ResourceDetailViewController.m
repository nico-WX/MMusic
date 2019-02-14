//
//  ResourceDetailViewController.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/21.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "MPMusicPlayerController+ResourcePlaying.h"

#import "ResourceDetailViewController.h"

#import "ResourceDetailHeadView.h"
#import "ResourceDetailSongCell.h"
#import "AlbumSongTableCell.h"
#import "PlaylistSongTableCell.h"

#import "ResourceDetailDataSource.h"
#import "SongCell.h"
#import "Resource.h"
#import "Song.h"



@interface ResourceDetailViewController ()<UITableViewDelegate,ResourceDetailDataSourceDelegate>
@property(nonatomic, strong) Resource *resource;

@property(nonatomic, strong) ResourceDetailHeadView *headView;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) ResourceDetailDataSource *dataSource;
@end

static NSString *const identifier = @"cell identifier";
@implementation ResourceDetailViewController

- (instancetype)initWithResource:(Resource *)resource{
    if (self = [super init]) {
        _resource = resource;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self.tableView setTableHeaderView:self.headView];
    [self.headView setFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), 200)];
    [self.headView setResource:_resource];

    //注册不同的类型cell
    Class cellClass;
    if ([_resource.type isEqualToString:@"playlists"]) {
        cellClass = [PlaylistSongTableCell class];
    }else{
        cellClass = [AlbumSongTableCell class];
    }
    [self.tableView registerClass:cellClass forCellReuseIdentifier:identifier];

    [self.view addSubview:self.tableView];
    self.dataSource = [[ResourceDetailDataSource alloc] initWithTableView:self.tableView
                                                               identifier:identifier
                                                                 resource:self.resource
                                                                 delegate:self];
}
- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];

    [_tableView setFrame:self.view.bounds];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [MainPlayer playSongs:[self.dataSource songLists] startIndex:indexPath.row];
}

#pragma mark - ResourceDetailDataSourceDelegate
- (void)configureCell:(UITableViewCell *)cell object:(Song *)song atIndex:(NSUInteger)index{

    if ([cell isKindOfClass:[AlbumSongTableCell class]]) {
        [((AlbumSongTableCell*)cell) setSong:song withIndex:index];
    }else{
        [((PlaylistSongTableCell*)cell) setSong:song];
    }
}

#pragma mark - settter/gettter
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView registerClass:[ResourceDetailSongCell class] forCellReuseIdentifier:identifier];
        [_tableView setRowHeight:55];
        [_tableView setDelegate:self];
    }
    return _tableView;
}

- (ResourceDetailHeadView *)headView{
    if (!_headView) {
        _headView = [[ResourceDetailHeadView alloc] init];
    }
    return _headView;
}

@end
