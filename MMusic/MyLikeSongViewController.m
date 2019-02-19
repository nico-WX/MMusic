//
//  MyLikeSongViewController.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/2/12.
//  Copyright © 2019 com.😈. All rights reserved.
//


#import "MyLikeSongViewController.h"
#import "UITableView+Extension.h"

#import "TableSongCell.h"
#import "MyLikeSongDataSource.h"
#import "Song.h"

@interface MyLikeSongViewController ()<UITableViewDelegate,MyLikeSongDataSourceDelegate>
@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong)MyLikeSongDataSource *dataSource;
@end

static NSString * const identifier = @"like song cell";
@implementation MyLikeSongViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.tableView];
    self.dataSource = [[MyLikeSongDataSource alloc] initWithTableVoew:self.tableView identifier:identifier delegate:self];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self.tableView setFrame:self.view.bounds];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView registerClass:[TableSongCell class] forCellReuseIdentifier:identifier];
        [_tableView setRowHeight:66];
        [_tableView setDelegate:self];
        [_tableView hiddenSurplusSeparator];
    }
    return _tableView;
}

#pragma mark - delegate
- (void)configureTableCell:(TableSongCell *)cell songManageObject:(SongManageObject *)song{
    [cell configureForSongManageObject:song];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray<SongManageObject*> *array = [self.dataSource songList];
    NSMutableArray<Song*> *songArray = [NSMutableArray array];
    for (SongManageObject *smo in array) {
        Song *song = [Song instanceWithSongManageObject:smo];
        [songArray addObject:song];
    }
    [MainPlayer playSongs:songArray startIndex:indexPath.row];
}


@end
