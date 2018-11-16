//
//  MMDetailViewController.m
//  ScrollPage
//
//  Created by 🐙怪兽 on 2018/11/12.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <Masonry.h>
#import <MJRefresh.h>
#import <MediaPlayer/MediaPlayer.h>

#import "MPMusicPlayerController+ResourcePlaying.h"

#import "MMDetailViewController.h"

#import "SongCell.h"

#import "Resource.h"
#import "Song.h"

@interface MMDetailViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;

@property(nonatomic, assign) CGFloat topOffset;
//data
@property(nonatomic, strong)Resource *resource;
@property(nonatomic, strong)NSArray<Song*> *songLists;
@end

static NSString *const reuseIdentifier = @"tableview cell id";
@implementation MMDetailViewController

- (instancetype)initWithResource:(Resource *)resource{
    if (self = [super init]) {
        _resource = resource;
        _imageView = [UIImageView new];
        _titleLabel = [UILabel new];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    //table
    ({
        self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [self.tableView registerClass:[SongCell class] forCellReuseIdentifier:reuseIdentifier];
        [self.tableView setBackgroundColor:[UIColor colorWithWhite:1 alpha:0]];
        [self.tableView setRowHeight:44.0f];
    });

    //添加子视图, 注意视图层次 & set
    ({
        [self.view addSubview:self.imageView];
        [self.view addSubview:self.titleLabel];
        [self.view addSubview:self.tableView];

        [self.view setBackgroundColor:UIColor.whiteColor];
        [self.view.layer setCornerRadius:6.0f];
        [self.view.layer setMasksToBounds:YES];
    });

    [self requestDataWithResource:self.resource];
}


- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];

    UIEdgeInsets padding =UIEdgeInsetsMake(0, 100, 0, 100);
    UIView *superView = self.view;
    CGRect frame = self.view.frame;
    //计算frame  提前滚动偏移
    self.imageView.frame = ({
        CGFloat x = padding.left;
        CGFloat y = 0;
        CGFloat w = CGRectGetWidth(frame)-padding.left-padding.right;
        CGFloat h = w;
        CGRectMake(x, y, w, h);
    });

    self.titleLabel.frame = ({
        CGFloat x = 0; //CGRectGetMinX(frame);
        CGFloat y = CGRectGetMaxY(self.imageView.frame);
        CGFloat h = 40; //显式设置高度, 方便计算tableView偏移
        CGFloat w = CGRectGetWidth(frame);
        CGRectMake(x, y, w, h);
    });
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(superView);
    }];

    //向下偏移量
    ({
        self.topOffset = CGRectGetMaxY(self.titleLabel.frame)+8;
        [self.tableView setContentInset:UIEdgeInsetsMake(self.topOffset, 0, 0, 0)];
        [self.tableView setContentOffset:CGPointMake(0, -self.topOffset)];
    });

}


#pragma mark - <TableView dataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.songLists.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SongCell *cell = (SongCell*)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    [cell setSong:[self.songLists objectAtIndex:indexPath.row] withIndex:indexPath.row];
    return cell;
}
#pragma mark - <TableView Delegate>
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [MainPlayer playSongs:self.songLists startIndex:indexPath.row];
}
#pragma mark - <scroll delegate>
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat y = scrollView.contentOffset.y;

    if ( y < -(self.topOffset+100)) {
        //下拉一段距离  关闭VC
        [self delegateDismissViewController];
    }
}
#pragma mark - <Dismiss ViewController dlelegate>
- (void)delegateDismissViewController{
    if ([self.disMissDelegate respondsToSelector:@selector(detailViewControllerDidDismiss:)]) {
        [self.disMissDelegate detailViewControllerDidDismiss:self];
    }
}

# pragma mark - requestData
/**请求数据*/
- (void) requestDataWithResource:(Resource*) resource{

    NSURLRequest *request = [self createRequestWithHref:self.resource.href];
    [self dataTaskWithRequest:request handler:^(NSDictionary *json, NSHTTPURLResponse *response) {
        self.songLists = [self serializationJSON:json];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];

}
//-(void) loadNextPageDataWithHref:(NSString*) href{
//    NSURLRequest *request = [self createRequestWithHref:href];
//    [self dataTaskWithRequest:request handler:^(NSDictionary *json, NSHTTPURLResponse *response) {
//        json =[json valueForKeyPath:@"results.songs"];
//
//        //覆盖next url,  增加song
//        self.responseRoot.next = [json valueForKey:@"next"];
//        for (NSDictionary *dict in [json valueForKey:@"data"]) {
//            Song *song = [Song instanceWithDict:[dict valueForKey:@"attributes"]];
//            self.songs = [self.songs arrayByAddingObject:song];
//        }
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.tableView.mj_footer endRefreshing];
//            [self.tableView reloadData];
//        });
//    }];
//}

/**解析返回的JSON 数据*/
- (NSArray<Song*>*) serializationJSON:(NSDictionary*)json{
    NSMutableArray<Song*> *songList = [NSMutableArray array];
    for (NSDictionary *temp in [json objectForKey:@"data"]) {
        NSArray *tracks = [temp valueForKeyPath:@"relationships.tracks.data"];
        for (NSDictionary *songDict in tracks) {
            Song *song = [Song instanceWithDict:[songDict objectForKey:@"attributes"]];
            [songList addObject:song];
        }
    }
    return songList;
}


@end
