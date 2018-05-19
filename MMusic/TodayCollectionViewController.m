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

#import "TodayCollectionViewController.h"
#import "PlayerViewController.h"
#import "AlbumCell.h"
#import "TodaySectionView.h"
#import "DetailViewController.h"
#import "SearchViewController.h"

#import "PersonalizedRequestFactory.h"
#import "Resource.h"
#import "Artwork.h"
#import "Playlist.h"
#import "Album.h"

@interface TodayCollectionViewController()<UICollectionViewDelegate, UICollectionViewDataSource>
@property(nonatomic, strong) MPMusicPlayerController *playerCtr;
@property(nonatomic, strong) UIButton *playbackViewButton;                      //右上角播放器指示器按钮
@property(nonatomic, strong) NAKPlaybackIndicatorView *playbackIndicatorView;   //播放器视图(添加到上面的按钮中)
@property(nonatomic, strong) UIActivityIndicatorView *activityView;     //加载指示器
@property(nonatomic, strong) NSArray<NSString*> *titles;                //节title
@property(nonatomic, strong) NSArray<NSArray<Resource*>*> *resources;   //所有资源
@property(nonatomic, strong) UICollectionView *collectionView;          //推荐内容
@property(nonatomic, strong) SearchViewController *searchVC;            //搜索控制器
@end

static const CGFloat row = 2.0f;
static const CGFloat miniSpacing = 2.0f;

@implementation TodayCollectionViewController
//reuse  identifier
static NSString *const sectionIdentifier = @"sectionView";
static NSString *const cellIdentifier = @"todayCell";

#pragma mark - cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.whiteColor;
    [self requestData];

    //搜索栏
    self.searchVC = SearchViewController.new;
    [self addChildViewController:self.searchVC];
    //添加到导航栏
    [self.navigationController.navigationBar addSubview:self.searchVC.serachBar];
    //添加搜索提示和结果视图
    [self.view addSubview:self.searchVC.view];

    //显示播放器按钮
    [self.navigationController.navigationBar addSubview:self.playbackViewButton];

    //推荐内容
    [self.view insertSubview:self.collectionView belowSubview:self.searchVC.view];

    //添加加载指示器
    [self.collectionView addSubview:self.activityView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    //显示搜搜框(搜索/显示详细时, 会隐藏搜索框)
    [self.searchVC.serachBar setHidden:NO];

    //layout
    __weak typeof(self) weakSelf = self;
    UIView *superview = self.navigationController.navigationBar;
    [self.searchVC.serachBar mas_makeConstraints:^(MASConstraintMaker *make) {
        UIEdgeInsets padding = UIEdgeInsetsMake(0, 0, 0, 60);
        make.edges.mas_equalTo(superview).with.insets(padding);
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

    //更新指示器
    switch (self.playerCtr.playbackState) {
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

#pragma  mark - 请求数据 和解析JSON
- (void)requestData {
    //个人数据请求
    PersonalizedRequestFactory *fac = [PersonalizedRequestFactory new];
    NSURLRequest *request = [fac fetchRecommendationsWithType:FetchDefaultRecommendationsType andIds:@[]];
    //[fac createRequestWithType:PersonalizedDefaultRecommendationsType resourceIds:@[]];
    [self dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary * json= [self serializationDataWithResponse:response data:data error:error];
        if (json) {
            NSMutableArray *tempList = NSMutableArray.new;  //所有数据临时集合
            NSMutableArray *titleList = NSMutableArray.new; //临时节title 集合

            for (NSDictionary *subJSON in [json objectForKey:@"data"]) {
                NSString *title = [subJSON valueForKeyPath:@"attributes.title.stringForDisplay"];
                if (!title) {
                    NSArray *list = [subJSON valueForKeyPath:@"relationships.contents.data"];
                    title = [list.firstObject valueForKeyPath:@"attributes.curatorName"];
                }
                [titleList addObject:title];
                //解析
                [tempList addObject:[self serializationJSON:subJSON]];
            }

            //所有数据解析完成, 设置数据
            self.resources = tempList;
            self.titles = titleList;
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
    return self.resources.count;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.resources objectAtIndex:section].count;
}

//cell
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    AlbumCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    Resource* resource = [[self.resources objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if ([resource respondsToSelector:@selector(attributes)]) {
        Artwork *artwork = [Artwork instanceWithDict:[resource.attributes valueForKey:@"artwork"]];
        [self showImageToView:cell.artworkView withImageURL:artwork.url cacheToMemory:YES];

        cell.titleLabel.text = [resource.attributes valueForKey:@"name"];
    }
    cell.contentView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1];

    return cell;
}

//头尾
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    //节头
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        NSString *title = [self.titles objectAtIndex:indexPath.section];
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
    Resource *obj = [[self.resources objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    DetailViewController *detailVC = [[DetailViewController alloc] initWithResource:obj];
    [self.searchVC.serachBar setHidden:YES];
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - getter
-(UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = UICollectionViewFlowLayout.new;
        layout.scrollDirection =  UICollectionViewScrollDirectionVertical;
        layout.sectionHeadersPinToVisibleBounds = YES;
        layout.minimumLineSpacing = miniSpacing;
        layout.minimumInteritemSpacing = miniSpacing;

        //cell size
        CGFloat cellW = CGRectGetWidth(self.view.bounds)-((row+1)*miniSpacing);
        cellW = cellW/row;                  //单个cell 宽度
        CGFloat cellH = cellW + 28;
        [layout setItemSize:CGSizeMake(cellW, cellH)];

        //section size
        CGFloat h = 44.0f;
        CGFloat w = CGRectGetWidth(self.view.bounds);
        [layout setHeaderReferenceSize:CGSizeMake(w, h)];


        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        [_collectionView registerClass:AlbumCell.class forCellWithReuseIdentifier:cellIdentifier];
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

-(NAKPlaybackIndicatorView *)playbackIndicatorView{
    if (!_playbackIndicatorView) {
        NAKPlaybackIndicatorViewStyle *style = [NAKPlaybackIndicatorViewStyle iOS10Style];
        _playbackIndicatorView = [[NAKPlaybackIndicatorView alloc] initWithStyle:style];
        //不接收事件
        [_playbackIndicatorView setUserInteractionEnabled:NO];
    }
    return _playbackIndicatorView;
}
-(UIButton *)playbackViewButton{
    if (!_playbackViewButton) {
        _playbackViewButton = [[UIButton alloc] init];

        //将播放指示视图 添加到按钮上
        [_playbackViewButton addSubview:self.playbackIndicatorView];
        //事件处理(显示控制器)
        [_playbackViewButton handleControlEvent:UIControlEventTouchUpInside withBlock:^{
            [self presentViewController:[PlayerViewController sharePlayerViewController] animated:YES completion:nil];
        }];
    }
    return _playbackViewButton;
}

-(MPMusicPlayerController *)playerCtr{
    if (!_playerCtr) {
        _playerCtr = [PlayerViewController sharePlayerViewController].playerController;
    }
    return _playerCtr;
}



@end
