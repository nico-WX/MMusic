//
//  TodayCollectionViewController.m
//  MMusic
//
//  Created by Magician on 2017/12/26.
//  Copyright © 2017年 com.😈. All rights reserved.
//
#import <MediaPlayer/MediaPlayer.h>
#import <NAKPlaybackIndicatorView.h>
#import <UIImageView+WebCache.h>
#import <MJRefresh.h>
#import <Masonry.h>

#import "TodayRecommendationViewController.h"
#import "PlayerViewController.h"
#import "ResourceCollectionViewCell.h"
#import "AlbumsCollectionCell.h"
#import "TodaySectionView.h"
#import "DetailViewController.h"
#import "SearchViewController.h"
#import "ResourceCell.h"

#import "MusicKit.h"
#import "Resource.h"
#import "Artwork.h"
#import "Playlist.h"
#import "Album.h"


@interface TodayRecommendationViewController()<UICollectionViewDelegate, UICollectionViewDataSource>
@property(nonatomic, strong) UIButton *playbackViewButton;                      //右上角播放器指示器按钮(占位)
@property(nonatomic, strong) NAKPlaybackIndicatorView *playbackIndicatorView;   //播放器视图(添加到上面的按钮中)
@property(nonatomic, strong) UIActivityIndicatorView *activityView;     //内容加载指示器
@property(nonatomic, strong) UICollectionView *collectionView;          //内容ui
@property(nonatomic, strong) SearchViewController *searchVC;            //搜索控制器

@property(nonatomic, strong) NSArray<NSDictionary<NSString*,NSArray<Resource*>*>*> *allData;

@end

static const CGFloat row = 2.0f;
static const CGFloat miniSpacing = 2.0f;

@implementation TodayRecommendationViewController
//reuse  identifier
static NSString *const sectionIdentifier = @"sectionView";
static NSString *const cellIdentifier = @"todayCell";

#pragma mark - cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.whiteColor;
    [self requestData];

    /**
     1.添加搜索栏到导航栏
     2.添加搜索控制器视图到视图中, 高度为0 隐藏在导航栏下方
     */
    //搜索栏
    self.searchVC = SearchViewController.new;
    [self addChildViewController:self.searchVC];
    [self.navigationController.navigationBar addSubview:self.searchVC.serachBar];
    [self.view addSubview:self.searchVC.view];


    //显示播放器视图 按钮,(将播放状态指示器添加到这按钮上)
    [self.playbackViewButton addSubview:self.playbackIndicatorView];
    [self.navigationController.navigationBar addSubview:self.playbackViewButton];

    //推荐内容
    [self.view insertSubview:self.collectionView belowSubview:self.searchVC.view];

    //加载遮罩 (mask)
    [self.collectionView addSubview:self.activityView];

//
//    [[MusicKit new].api resources:@[@"1315876389",] byType:CatalogSongs callBack:^(NSDictionary *json, NSHTTPURLResponse *response) {
//        Log(@"CODE =%ld ,json==%@",response.statusCode, json);
//    }];
//    [[MusicKit new].api resources:@[@"1315876",] byType:CatalogSongs callBack:^(NSDictionary *json, NSHTTPURLResponse *response) {
//        Log(@"02 CODE =%ld ,json==%@",response.statusCode, json);
//    }];
//
//    [MusicKit.new.api resources:@[@"300117743",] byType:CatalogArtists callBack:^(NSDictionary *json, NSHTTPURLResponse *response) {
//        Log(@"json =%@",json);
//    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//更新UI
-(void)viewDidAppear:(BOOL)animated{
    //显示搜搜框(搜索/显示详细时, 会隐藏搜索框)
    [self.searchVC.serachBar setHidden:NO];

    //更新指示器
    switch ([PlayerViewController sharePlayerViewController].playerController.playbackState) {
        case MPMusicPlaybackStatePaused:
        case MPMusicPlaybackStateStopped:
        case MPMusicPlaybackStateInterrupted:
            [self.playbackIndicatorView setState:NAKPlaybackIndicatorViewStatePaused];
            break;

        default:
            [self.playbackIndicatorView setState:NAKPlaybackIndicatorViewStatePlaying];
            break;
    }
}
//布局
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    //layout
    __weak typeof(self) weakSelf = self;
    UIView *superview = self.navigationController.navigationBar;
    [self.searchVC.serachBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(superview).with.insets(UIEdgeInsetsMake(0, 0, 0, 60));
    }];

    [self.playbackViewButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superview.mas_top);
        make.right.mas_equalTo(superview.mas_right).offset(-8);
        make.bottom.mas_equalTo(superview.mas_bottom);
        make.width.mas_equalTo(CGRectGetHeight(weakSelf.navigationController.navigationBar.frame));
    }];

    superview = self.playbackViewButton;
    [self.playbackIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(superview).insets(UIEdgeInsetsZero);
    }];

    superview = self.view;
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        //计算 导航栏  及 tabBar 高度
        CGFloat y = CGRectGetMaxY(weakSelf.navigationController.navigationBar.frame);
        CGFloat tabBatH = CGRectGetHeight(weakSelf.tabBarController.tabBar.frame);
        UIEdgeInsets insets = UIEdgeInsetsMake(miniSpacing+y, miniSpacing, miniSpacing+tabBatH, miniSpacing);
        make.edges.mas_equalTo(superview).with.insets(insets);
    }];
}

#pragma  mark - 请求数据 和解析JSON
- (void)requestData {
    [[MusicKit new].api.library defaultRecommendationsInCallBack:^(NSDictionary *json, NSHTTPURLResponse *response) {
        //数据列表
        NSMutableArray<NSDictionary<NSString*,NSArray*>*> *array = [NSMutableArray array];

        for (NSDictionary *subJSON in [json objectForKey:@"data"]) {
            //获取title
            NSString *title = [subJSON valueForKeyPath:@"attributes.title.stringForDisplay"];
            if (!title) {
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
            [self.activityView stopAnimating];

            [self.collectionView reloadData];
            [self.collectionView.mj_header endRefreshing];
        });
    }];
}
/**解析JSON 数据*/
-(NSArray<Resource*>*) serializationJSON:(NSDictionary*) json{
    NSMutableArray<Resource*> *sectionList = [NSMutableArray array];  //节数据临时集合
    json = [json objectForKey:@"relationships"];
    NSDictionary *contents = [json objectForKey:@"contents"];  //如果这里有内容, 则不是组推荐, 没有值就是组推荐
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
//    ResourceCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
//
    NSDictionary<NSString*,NSArray<Resource*>*> *dict = [self.allData objectAtIndex:indexPath.section];
    Resource* resource = [dict.allValues.firstObject objectAtIndex:indexPath.row];
//
//    cell.nameLabel.text = [resource.attributes valueForKey:@"name"];
//    Artwork *artwork = [Artwork instanceWithDict:[resource.attributes valueForKey:@"artwork"]];
//    [self showImageToView:cell.artworkView withImageURL:artwork.url cacheToMemory:YES];
//

    ResourceCell *cell = (ResourceCell*)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
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
        header.backgroundColor = collectionView.backgroundColor;
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

        CGFloat cw = CGRectGetWidth(self.view.frame) - 80;
        CGFloat ch = cw *1.5;
        [layout setItemSize:CGSizeMake(cw, ch)];
        [layout setMinimumLineSpacing:20];
        [layout setMinimumInteritemSpacing:40];
        [layout setSectionInset:UIEdgeInsetsMake(20, 0, 20, 0)]; //cell 与头尾间距
        [layout setSectionHeadersPinToVisibleBounds:YES];

        //section size
        CGFloat h = 44.0f;
        CGFloat w = CGRectGetWidth(self.view.bounds);
        [layout setHeaderReferenceSize:CGSizeMake(w, h)];

        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        [_collectionView registerClass:ResourceCell.class forCellWithReuseIdentifier:cellIdentifier];
        //[_collectionView registerClass:ResourceCollectionViewCell.class forCellWithReuseIdentifier:cellIdentifier];
        //[_collectionView registerClass:AlbumCell.class forCellWithReuseIdentifier:cellIdentifier];
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
            [self presentViewController:[PlayerViewController sharePlayerViewController] animated:YES completion:nil];
        }];
    }
    return _playbackViewButton;
}
-(NAKPlaybackIndicatorView *)playbackIndicatorView{
    return [PlayerViewController sharePlayerViewController].playbackIndicatorView;
}

@end
