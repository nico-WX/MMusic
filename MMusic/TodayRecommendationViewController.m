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


#import "MusicKit.h"
#import "PersonalizedRequestFactory.h"
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

    //test
    MusicKit *music = [MusicKit new];
//    [music.api resources:@[@"535790918",] byType:CatalogAlbums callBack:^(NSDictionary *json) {
//        Log(@"json ===> %@",json);
//    }];
//    [music.api songsByISRC:@[@"TWK970000106",] callBack:^(NSDictionary *json) {
//        Log(@"json ===========>>>>> %@",json);
//    }];
//    [music.api relationship:@"535791114" byType:CatalogSongs forName:@"albums" callBack:^(NSDictionary *json) {
//        Log(@"json RElationship ===========>>>>> %@",json);
//    }];
//    [music.api.library resource:nil byType:CLibrarySongs callBack:^(NSDictionary *json) {
//        NSLog(@"json =%@",json);
//    }];
//    [music.api.library relationship:@"i.EYVbDrZuVPeVXQ" forType:CLibrarySongs byName:@"albums" callBacl:^(NSDictionary *json) {
//         NSLog(@"json ==========>%@",json);
//    }];

//    [music.api searchForTerm:@"周" callBack:^(NSDictionary *json) {
//        Log(@"json=%@",json);
//    }];
//    [music.api.library defaultRecommendationsInCallBack:^(NSDictionary *json) {
//        Log(@"json=%@",json);
//    }];

//    [music.api.library resource:nil byType:CLibraryPlaylists callBack:^(NSDictionary *json) {
//        Log(@"json =%@",json);
//    }];


//    NSDictionary *json = @{@"id":@"1125331139",@"type":@"songs"};
//    [music.api.library addTracksToLibraryPlaylists:@"p.YJXV7bvIl7JlzV" playload:json];
//    NSDictionary *dict = @{@"type":@"rating",@"attributes":@{@"value":@1}};
//    NSDictionary *playload = @{@"type":@"rating",@"attributes":@{@"value":@1}};
    [music.api.library addRating:@"1333861909" byType:CRatingSongs value:-1 callBack:^(NSDictionary *json){
        Log(@"json=%@",json);
    }];

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
    //个人数据请求
    PersonalizedRequestFactory *fac = [PersonalizedRequestFactory new];
    NSURLRequest *request = [fac fetchRecommendationsWithType:FetchDefaultRecommendationsType andIds:@[]];

    [self dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary * json= [self serializationDataWithResponse:response data:data error:error];
        if (json) {

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
        }
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
    ResourceCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];

    NSDictionary<NSString*,NSArray<Resource*>*> *dict = [self.allData objectAtIndex:indexPath.section];
    Resource* resource = [dict.allValues.firstObject objectAtIndex:indexPath.row];

    cell.nameLabel.text = [resource.attributes valueForKey:@"name"];
    Artwork *artwork = [Artwork instanceWithDict:[resource.attributes valueForKey:@"artwork"]];
    [self showImageToView:cell.artworkView withImageURL:artwork.url cacheToMemory:YES];
    
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
        layout.minimumLineSpacing = miniSpacing;
        layout.minimumInteritemSpacing = miniSpacing;

        //cell size(提前设置, 请求图片时 需要使用大小参数)
        CGFloat cellW = CGRectGetWidth(self.view.bounds)-((row+1)*miniSpacing);
        cellW = cellW/row;                  //单个cell 宽度
        CGFloat cellH = cellW + 28;         //28 高度标签
        [layout setItemSize:CGSizeMake(cellW, cellH)];

        //section size
        CGFloat h = 44.0f;
        CGFloat w = CGRectGetWidth(self.view.bounds);
        [layout setHeaderReferenceSize:CGSizeMake(w, h)];

        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        [_collectionView registerClass:ResourceCollectionViewCell.class forCellWithReuseIdentifier:cellIdentifier];
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
