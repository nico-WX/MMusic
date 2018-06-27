//
//  LocalMusicViewController.m
//  MMusic
//
//  Created by Magician on 2017/11/6.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "LocalMusicViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <StoreKit/StoreKit.h>
#import <Masonry.h>

@interface LocalMusicViewController ()<UITableViewDelegate, UITableViewDataSource>
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSArray<MPMediaItem*>  *items;
@property(nonatomic, strong) NSArray<MPMediaQuerySection*> *itemSection;
@property(nonatomic, strong) MPMediaQuery  *query;
@property(nonatomic, strong) MPMediaItem  *nowPlayerItem;

@end

static NSString *reuseID = @"localMusicCellIdentifier";
@implementation LocalMusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setTitle:@"本地歌曲"];
  //  self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.view setBackgroundColor:UIColor.whiteColor];
    [self.view addSubview:self.tableView];

    //读取本地音乐数据
    [SKCloudServiceController requestAuthorization:^(SKCloudServiceAuthorizationStatus status) {
        if (status == SKCloudServiceAuthorizationStatusAuthorized) {

//            self.itemSection = [MPMediaQuery new].itemSections;
//            for (MPMediaQuerySection *section in self.itemSection) {
//                MPMediaQuery *query = [MPMediaQuery new];
//                MPMediaPropertyPredicate *pre = [MPMediaPropertyPredicate predicateWithValue:section.title forProperty:@"title" comparisonType:MPMediaPredicateComparisonContains];
//                [query addFilterPredicate:pre];
//
//                NSArray *temp = [query items];
//
//                for (MPMediaItem *item in temp) {
//                    Log(@"title =%@",item.title);
//                }
//
//                NSString *name = @"sfasdfas";
//            }

            self.query = [MPMediaQuery songsQuery];
            self.items = [self.query items];

            //刷新数据
            [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
        }
    }];

    //布局
    UIView *superview = self.view;
    typeof(self) weakSelf = self;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superview.mas_top).offset(CGRectGetMaxY(weakSelf.navigationController.navigationBar.frame));
        make.left.mas_equalTo(superview.mas_left);
        make.right.mas_equalTo(superview.mas_right);
        CGFloat bottomOffset = CGRectGetHeight(weakSelf.tabBarController.tabBar.frame);
        make.bottom.mas_equalTo(superview.mas_bottom).offset(-bottomOffset);
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID forIndexPath:indexPath];
    MPMediaItem *item = [self.items objectAtIndex:indexPath.row];
    [cell.textLabel setText:item.title];
    return cell;
}
-(NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    NSMutableArray *array = [NSMutableArray array];
    for (MPMediaQuerySection *section in self.itemSection) {
        [array addObject:section.title];
    }
    return array;
}
-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];

    return 30;
}

#pragma mark -table View delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MPMusicPlayerController *player = [MPMusicPlayerController systemMusicPlayer];
    MPMediaItem *item = [self.items objectAtIndex:indexPath.row];
    [player setQueueWithQuery:self.query];
    [player setNowPlayingItem:item];
    if (player.playbackState == MPMusicPlaybackStatePlaying && self.nowPlayerItem == player.nowPlayingItem) {
        [player pause];
        return;
    }
    self.nowPlayerItem = item;
    [player play];
}




// Overre to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [_tableView registerClass:UITableViewCell.class forCellReuseIdentifier:reuseID];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

@end
