//
//  TodayCollectionViewController.m
//  MMusic
//
//  Created by Magician on 2017/12/26.
//  Copyright © 2017年 com.😈. All rights reserved.
//

//frameworks
#import <MediaPlayer/MediaPlayer.h>
#import <NAKPlaybackIndicatorView.h>
#import <UIImageView+WebCache.h>
#import <MJRefresh.h>
#import <Masonry.h>

//controller
#import "TodayRecommendationViewController.h"
#import "PlayerViewController.h"
#import "DetailViewController.h"
#import "SearchViewController.h"

//view
#import "TodaySectionView.h"
#import "ResourceCell.h"
#import "ResourceCell_V2.h"

//model
#import "MusicKit.h"
#import "Resource.h"
#import "Artwork.h"
#import "Playlist.h"
#import "Album.h"

//other
#import "JSONKey.h"

@interface TodayRecommendationViewController()<UICollectionViewDelegate, UICollectionViewDataSource>
@property(nonatomic, strong) UIButton *playbackViewButton;                      //右上角播放器指示器按钮(占位)
@property(nonatomic, strong) NAKPlaybackIndicatorView *playbackIndicatorView;   //播放器视图(添加到上面的按钮中)
@property(nonatomic, strong) UIActivityIndicatorView *activityView;     //内容加载指示器
@property(nonatomic, strong) UICollectionView *collectionView;          //内容ui
@property(nonatomic, strong) SearchViewController *searchVC;            //搜索控制器


//json 结构
@property(nonatomic, strong) NSArray<NSDictionary<NSString*,NSArray<Resource*>*>*> *allData;
@end


@implementation TodayRecommendationViewController
//reuse  identifier
static NSString *const sectionIdentifier = @"sectionView";
static NSString *const cellIdentifier = @"todayCell";

#pragma mark - cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.whiteColor;
    [self requestData];
    [self setupNavigationSubview];


    //推荐内容
    [self.view insertSubview:self.collectionView belowSubview:self.searchVC.view];

    //加载遮罩 (mask)
    [self.collectionView addSubview:self.activityView];

    __weak typeof(self) weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        MPMusicPlayerController *player = note.object;
        switch (player.playbackState) {
            case MPMusicPlaybackStatePlaying:
                [weakSelf.playbackIndicatorView setState:NAKPlaybackIndicatorViewStatePlaying];
                break;

            default:
                [weakSelf.playbackIndicatorView setState:NAKPlaybackIndicatorViewStatePaused];
                break;
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//更新UI
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //显示搜索栏(进入搜索结果时会隐藏)
    [self.searchVC.serachBar setHidden:NO];

    //更新指示器
    PlayerViewController *playerVC = [PlayerViewController sharePlayerViewController];
    switch (playerVC.playerController.playbackState) {
        case MPMusicPlaybackStatePaused:
        case MPMusicPlaybackStateStopped:
        case MPMusicPlaybackStateInterrupted:
            [self.playbackIndicatorView setState:NAKPlaybackIndicatorViewStatePaused];
            break;

            //播放,快进退
        default:
            [self.playbackIndicatorView setState:NAKPlaybackIndicatorViewStatePlaying];
            break;
    }
}

//调整集合视图
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    //layout collectionView
    __weak typeof(self) weakSelf = self;
    UIView *superview = self.view;
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat topOffset = CGRectGetMaxY(weakSelf.navigationController.navigationBar.frame);
        CGFloat bottomOffset = CGRectGetHeight(weakSelf.tabBarController.tabBar.frame);
        make.edges.mas_equalTo(superview).insets(UIEdgeInsetsMake(topOffset, 0, bottomOffset, 0));
    }];
}

#pragma mark - 设置导航栏子视图
- (void)setupNavigationSubview{

    /**
     1.添加搜索栏到导航栏
     2.添加搜索控制器视图到视图中, 高度为0 隐藏在导航栏下方
     */
    //搜索栏
    self.searchVC = SearchViewController.new;
    [self addChildViewController:self.searchVC];
    [self.navigationController.navigationBar addSubview:self.searchVC.serachBar];
    [self.view addSubview:self.searchVC.view];

    //播放状态视图覆盖在按钮上,按钮响应弹出播放器界面事件
    [self.playbackViewButton addSubview:self.playbackIndicatorView];
    [self.navigationController.navigationBar addSubview:self.playbackViewButton];


    //layout
    __weak typeof(self) weakSelf = self;
    UIView *superview = self.navigationController.navigationBar;
    //左右偏移,搜索栏居中
    [self.searchVC.serachBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(superview).with.insets(UIEdgeInsetsMake(0, 60, 0, 60));
    }];

    [self.playbackViewButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superview.mas_top);
        make.bottom.mas_equalTo(superview.mas_bottom);
        make.left.mas_equalTo(weakSelf.searchVC.serachBar.mas_right).offset(8);
        make.right.mas_equalTo(superview.mas_right).offset(-8);
    }];

    superview = self.playbackViewButton;
    [self.playbackIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(superview).insets(UIEdgeInsetsZero);
    }];
}

#pragma  mark - 请求数据 和解析JSON
- (void)requestData {

    [MusicKit.new.api.library defaultRecommendationsInCallBack:^(NSDictionary *json, NSHTTPURLResponse *response) {
        //数据临时集合 [{@"section title":[data]},...]
        NSMutableArray<NSDictionary<NSString*,NSArray*>*> *array = [NSMutableArray array];

        for (NSDictionary *subJSON in [json objectForKey:@"data"]) {
            //获取 section title
            NSString *title = [subJSON valueForKeyPath:@"attributes.title.stringForDisplay"];
            if (!title) {
                //部分情况下无显示名称, 向下获取歌单维护者
                NSArray *list = [subJSON valueForKeyPath:@"relationships.contents.data"];
                title = [list.firstObject valueForKeyPath:@"attributes.curatorName"];
            }

            NSArray *resources = [self serializationJSON:subJSON];
            NSDictionary *dict = @{title:resources};
            [array addObject:dict];
        }
        self.allData = array;
        //刷新UI
        dispatch_async(dispatch_get_main_queue(), ^{
            //[self.activityView stopAnimating];
            [self.activityView removeFromSuperview];
            self.activityView = nil;

            [self.collectionView reloadData];
            [self.collectionView.mj_header endRefreshing];
        });
    }];
}

/**解析JSON 数据的嵌套*/
-(NSArray<Resource*>*) serializationJSON:(NSDictionary*) json{
    NSMutableArray<Resource*> *sectionList = [NSMutableArray array];  //section数据临时集合
    json = [json objectForKey:@"relationships"];
    NSDictionary *contents = [json objectForKey:@"contents"];  //如果这里有内容, 则不是组推荐,递归调用解析即可解析<组推荐json结构>
    if (contents) {
        //非组推荐
        for (NSDictionary *sourceDict in [contents objectForKey:@"data"]) {
            Resource *resouce = [Resource instanceWithDict:sourceDict];
            [sectionList addObject:resouce];
        }
    }else{
        //组推荐
        NSDictionary *recommendations = [json objectForKey:@"recommendations"];
        if (recommendations) {
            for (NSDictionary *subJSON  in [recommendations objectForKey:@"data"]) {
                //递归
                NSArray *temp =[self serializationJSON: subJSON];
                //数据添加
                [sectionList addObjectsFromArray:temp];
            }
        }
    }
    return sectionList;
}

#pragma mark - <UICollectionViewDataSource>
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return self.allData.count;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray *array = [self.allData objectAtIndex:section].allValues.firstObject;
    return  array.count;
}

//cell
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    //data
    NSDictionary<NSString*,NSArray<Resource*>*> *dict = [self.allData objectAtIndex:indexPath.section];
    Resource* resource = [dict.allValues.firstObject objectAtIndex:indexPath.row];

    //dequeue cell
    ResourceCell_V2 *cell;
    cell = (ResourceCell_V2*)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    //只有专辑和歌单两种类型;
    if ([resource.type isEqualToString:@"albums"]) {
        Album *album = [Album instanceWithResource:resource];
        cell.album = album;
    }else{
        Playlist *playlist = [Playlist instanceWithResource:resource];
        cell.playlists = playlist;
    }
    return cell;
}

//头尾
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    //节头
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        NSString *title = [self.allData objectAtIndex:indexPath.section].allKeys.firstObject;
        TodaySectionView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                      withReuseIdentifier:sectionIdentifier
                                                                             forIndexPath:indexPath];
        [header.titleLabel setText:title];
        return header;
    }
    return nil;
}

#pragma mark - UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    Resource *obj = [[[self.allData objectAtIndex:indexPath.section] allValues].firstObject objectAtIndex:indexPath.row];
    DetailViewController *detailVC = [[DetailViewController alloc] initWithResource:obj];
    //隐藏搜索栏, 返回时显示
    [self.searchVC.serachBar setHidden:YES];
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - getter
-(UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = UICollectionViewFlowLayout.new;
        layout.scrollDirection =  UICollectionViewScrollDirectionVertical;

        //两列
        CGFloat spacing = 8.0f;
        CGFloat cw = CGRectGetWidth(self.view.frame) - spacing*3;
        cw /= 2;
        CGFloat ch = cw+32;
        [layout setItemSize:CGSizeMake(cw, ch)];

        [layout setMinimumLineSpacing:spacing*2];
        [layout setMinimumInteritemSpacing:spacing];
        [layout setSectionInset:UIEdgeInsetsMake(spacing, spacing, spacing, spacing)]; //cell 与头尾间距
        //[layout setSectionHeadersPinToVisibleBounds:YES];

        //section size
        CGFloat h = 44.0f;
        CGFloat w = CGRectGetWidth(self.view.bounds);
        [layout setHeaderReferenceSize:CGSizeMake(w, h)];

        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        [_collectionView registerClass:ResourceCell_V2.class forCellWithReuseIdentifier:cellIdentifier];
        [_collectionView registerClass:TodaySectionView.class
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:sectionIdentifier];

        _collectionView.backgroundColor = UIColor.whiteColor;
        _collectionView.dataSource = self;
        _collectionView.delegate  = self;

        //刷新
        _collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [self requestData];
        }];
    }
    return _collectionView;
}
- (UIActivityIndicatorView *)activityView{
    if (!_activityView) {
        _activityView = [[UIActivityIndicatorView alloc] initWithFrame:self.collectionView.frame];
        [_activityView setHidesWhenStopped:YES];
        [_activityView setColor:[UIColor lightGrayColor]];
        [_activityView setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.96 alpha:0.9]];
        [_activityView startAnimating];
    }
    return _activityView;
}

-(UIButton *)playbackViewButton{
    if (!_playbackViewButton) {
        _playbackViewButton = [[UIButton alloc] init];
        //事件处理回调
        [_playbackViewButton handleControlEvent:UIControlEventTouchUpInside withBlock:^{
            PlayerViewController *playerVC = [PlayerViewController sharePlayerViewController];
            [self presentViewController:playerVC animated:YES completion:nil];
        }];
    }
    return _playbackViewButton;
}
-(NAKPlaybackIndicatorView *)playbackIndicatorView{
    if (!_playbackIndicatorView) {
        NAKPlaybackIndicatorViewStyle *style = [NAKPlaybackIndicatorViewStyle iOS10Style];
        _playbackIndicatorView = [[NAKPlaybackIndicatorView alloc] initWithStyle:style];
        [_playbackIndicatorView setUserInteractionEnabled:NO];
    }
    return _playbackIndicatorView;
}

@end
