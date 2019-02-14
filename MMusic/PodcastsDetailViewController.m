//
//  PodcastsDetailViewController.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/2/14.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "PodcastsDetailViewController.h"
#import "TableSongCell.h"

@interface PodcastsDetailViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)MPMediaItemCollection *itemCollection;
@property(nonatomic,strong)UITableView *tableView;
@end

static NSString *const identifier = @"table cell identifier";
@implementation PodcastsDetailViewController

- (instancetype)initWithMediaItemCollection:(MPMediaItemCollection *)itemCollection{
    if (self = [super init]) {
        _itemCollection = itemCollection;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self.view addSubview:self.tableView];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];

    [self.tableView setFrame:self.view.bounds];
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView registerClass:[TableSongCell class] forCellReuseIdentifier:identifier];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        [_tableView setRowHeight:50];
    }
    return _tableView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    MPMediaItemCollection *collection = [[MPMediaItemCollection alloc] initWithItems:self.itemCollection.items];
    MPMusicPlayerMediaItemQueueDescriptor *des = [[MPMusicPlayerMediaItemQueueDescriptor alloc] initWithItemCollection:collection];
    [des setStartItem:[collection.items objectAtIndex:indexPath.row]];
    [MainPlayer setQueueWithDescriptor:des];
    [MainPlayer play];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.itemCollection.items.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TableSongCell *cell = (TableSongCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    [cell configureForMediaItem:[self.itemCollection.items objectAtIndex:indexPath.row]];
    return cell;
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
