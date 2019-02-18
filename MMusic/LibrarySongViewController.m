//
//  LibrarySongViewController.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/2/12.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "LibrarySongViewController.h"
#import "TableSongCell.h"


@interface LibrarySongViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)MPMediaQuery *songQuery;
@end

static NSString * const identifier = @" lib song cell";
@implementation LibrarySongViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self.view addSubview: self.tableView];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];

    [self.tableView setFrame:self.view.bounds];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MPMediaItemCollection *collection = [[MPMediaItemCollection alloc] initWithItems:self.songQuery.items];
    MPMusicPlayerMediaItemQueueDescriptor *des = [[MPMusicPlayerMediaItemQueueDescriptor alloc] initWithItemCollection:collection];
    [des setStartItem:[self.songQuery.items objectAtIndex:indexPath.row]];
    [MainPlayer setQueueWithDescriptor:des];
    [MainPlayer play];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.songQuery.items.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TableSongCell *cell = (TableSongCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    [cell configureForMediaItem:[self.songQuery.items objectAtIndex:indexPath.row]];
    return cell;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView registerClass:[TableSongCell class] forCellReuseIdentifier:identifier];
        [_tableView setRowHeight:50];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
    }
    return _tableView;
}
- (MPMediaQuery *)songQuery{
    if (!_songQuery) {
        _songQuery = [MPMediaQuery songsQuery];
    }
    return _songQuery;
}
    


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
