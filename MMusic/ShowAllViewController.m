//
//  ShowAllViewController.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/21.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "ShowAllViewController.h"
#import "ShowAllDataSource.h"
#import "SongCollectionCell.h"
#import "ResourceDetailViewController.h"

#import "Chart.h"
#import "Resource.h"
#import "Song.h"
#import "MPMusicPlayerController+ResourcePlaying.h"

@interface ShowAllViewController ()<UICollectionViewDelegate,ShowAllDataSourceDelegate>
@property(nonatomic,strong) UICollectionViewFlowLayout *flowLayout;
@property(nonatomic,strong) UICollectionView *collectionView;

@property(nonatomic, strong) Chart *chart;
@property(nonatomic,strong) ShowAllDataSource *dataSource;

@end

static NSString *const identifier = @"cell dientifier";
@implementation ShowAllViewController

- (instancetype)initWithChart:(Chart *)chart{
    if (self = [super init]) {
        _chart = chart;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.collectionView];

    NSString *type = self.chart.data.firstObject.type;
    if ([type isEqualToString:@"songs"]) {
        [self.collectionView registerClass:[SongCollectionCell class] forCellWithReuseIdentifier:identifier];
        CGFloat w = CGRectGetWidth(self.view.bounds);
        CGFloat h = 55.0f;
        [self.flowLayout setItemSize:CGSizeMake(w, h)];
        [self.flowLayout setMinimumInteritemSpacing:0];
    }else{
        [self.collectionView registerClass:[ResourceCollectionCell class] forCellWithReuseIdentifier:identifier];
        UIEdgeInsets insets = UIEdgeInsetsMake(0, 8, 0, 8);
        [self.collectionView setContentInset:insets];
        CGFloat w = CGRectGetWidth(self.view.bounds)/2 - insets.left*2;
        CGFloat h = w+40;
        [self.flowLayout setItemSize:CGSizeMake(w, h)];
        [self.flowLayout setMinimumLineSpacing:8];
        [self.flowLayout setMinimumInteritemSpacing:8];
    }

    _dataSource = [[ShowAllDataSource alloc] initWithCollectionView:self.collectionView
                                                    reuseIdentifier:identifier
                                                              chart:self.chart
                                                           delegate:self];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];

    [_collectionView setFrame:self.view.bounds];
}
#pragma mark - UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    // 选中歌曲类型, 播放, 其他类型显示详细
    NSString *type = self.chart.data.firstObject.type;
    if ([type isEqualToString:@"songs"]) {
        NSMutableArray<Song*> *array = [NSMutableArray array];
        //数据源内部的数据会自动加载全部数据, 并设置到data 中
        for (Resource *resource in self.dataSource.chart.data) {
            [array addObject:[Song instanceWithResource:resource]];
        }
        [MainPlayer playSongs:array startIndex:indexPath.row];
    }else{
        Resource *resource = [self.dataSource.chart.data objectAtIndex:indexPath.row];
        ResourceDetailViewController *detailVC =[[ResourceDetailViewController alloc] initWithResource:resource];
        [detailVC setTitle:[resource.attributes valueForKey:@"name"]];
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}

#pragma mark - ShowAllDataSourceDelegate
-(void)configureCell:(UICollectionViewCell *)cell object:(Resource *)resource{
    if ([cell isKindOfClass:[ResourceCollectionCell class]]) {
        [((ResourceCollectionCell*)cell) setResource:resource];
    }
}

#pragma mark - setter/getter
-(UICollectionView *)collectionView{
    if (!_collectionView) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_flowLayout];
        [_collectionView setBackgroundColor:UIColor.whiteColor];
        [_collectionView setDelegate:self];
    }
    return _collectionView;
}

@end
