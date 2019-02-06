//
//  ShowAllSearchResultsViewController.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/24.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "ShowAllSearchResultsViewController.h"
#import "ShowAllSearchResultsDataSource.h"

#import "ResourceDetailViewController.h"

#import "SongCollectionCell.h"
#import "ResourceCollectionCell.h"

#import "MPMusicPlayerController+ResourcePlaying.h"
#import "ResponseRoot.h"
#import "Resource.h"
#import "Song.h"
#import "MusicVideo.h"

@interface ShowAllSearchResultsViewController ()<UICollectionViewDelegate,ShowAllSearchResultsDataSourceDelegate>
@property(nonatomic,strong)ResponseRoot *responseRoot;
@property(nonatomic,strong)UICollectionViewFlowLayout *layout;
@property(nonatomic,strong)UICollectionView *collectionView;
@property(nonatomic,strong)ShowAllSearchResultsDataSource *dataSource;
@end


static NSString *const identifier = @"cell identifier";
@implementation ShowAllSearchResultsViewController

- (instancetype)initWithResponseRoot:(ResponseRoot *)responseRoot{
    if (self = [super init]) {
        _responseRoot = responseRoot;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self.navigationItem setLargeTitleDisplayMode:UINavigationItemLargeTitleDisplayModeAlways];
    [self.view addSubview:self.collectionView];

    _dataSource = [[ShowAllSearchResultsDataSource alloc] initWithView:self.collectionView
                                                            identifier:identifier
                                                          responseRoot:self.responseRoot
                                                              delegate:self];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];

    [self.collectionView setFrame:self.view.bounds];

    // 不同的类型, 不同的cellSize  和cell 类型
    Resource *res = self.responseRoot.data.firstObject;
    if ([res.type isEqualToString:@"songs"]) {
        [self.collectionView registerClass:[SongCollectionCell class] forCellWithReuseIdentifier:identifier];
        CGFloat h = 80;
        CGFloat w = CGRectGetWidth(self.view.bounds);
        [self.layout setItemSize:CGSizeMake(w, h)];
        [self.layout setMinimumInteritemSpacing:1];
    }else{
        [self.collectionView registerClass:[ResourceCollectionCell class] forCellWithReuseIdentifier:identifier];

        CGFloat space = 8.0f;
        CGFloat w = CGRectGetWidth(self.view.bounds);
        w = (w-space*3)/2;
        CGFloat h = w+40;
        [self.layout setItemSize:CGSizeMake(w, h)];
        [self.layout setMinimumInteritemSpacing:space];
        [self.layout setMinimumLineSpacing:space];
        [self.collectionView setContentInset:UIEdgeInsetsMake(0, space, 0, space)];
    }
}

#pragma mark - getter/setter
-(UICollectionView *)collectionView{
    if (!_collectionView) {
        _layout = [[UICollectionViewFlowLayout alloc] init];

        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_layout];
        [_collectionView setBackgroundColor:UIColor.whiteColor];
        [_collectionView setDelegate:self];
    }
    return _collectionView;
}


#pragma mark - ShowAllSearchResultsDataSourceDelegate
- (void)configureCollectionCell:(UICollectionViewCell *)cell object:(Resource   *)resource{
    if ([cell isKindOfClass:[ResourceCollectionCell class]]) {
        [((ResourceCollectionCell*)cell) setResource:resource];
    }
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];

    NSArray<Resource*> *data = self.dataSource.data;
    Resource *res = data.firstObject;

    if ([res.type isEqualToString:@"songs"]) {

        NSMutableArray *songList = [NSMutableArray array];
        for (Resource *resource in data) {
            Song *song = [Song instanceWithResource:resource];
            [songList addObject:song];
        }
        [MainPlayer playSongs:songList startIndex:indexPath.row];

    }else if ([res.type isEqualToString:@"music-videos"]){
        NSMutableArray<MusicVideo*> *musicVideoList = [NSMutableArray array];
        for (Resource *resource in data) {
            MusicVideo *mv = [MusicVideo instanceWithResource:resource];
            [musicVideoList addObject:mv];
        }
        [MainPlayer playMusicVideos:musicVideoList startIndex:indexPath.row];

    }else{
        Resource *res = [((ResourceCollectionCell*)cell) resource];
        ResourceDetailViewController *detailVC = [[ResourceDetailViewController alloc] initWithResource:res];
        [detailVC.navigationItem setLargeTitleDisplayMode:UINavigationItemLargeTitleDisplayModeNever];
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}
@end
