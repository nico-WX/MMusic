//
//  MMSearchResultsViewController.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/25.
//  Copyright © 2018 com.😈. All rights reserved.
//


#import "MMSearchResultsViewController.h"
#import "MMSearchTopPageCell.h"
#import "MMSearchData.h"

@interface MMSearchResultsViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>
@property(nonatomic, strong) NSString *term;
@property(nonatomic, strong) MMSearchData *searchData;
@property(nonatomic, strong) NSArray<NSString*> *types;

//顶部分页段
@property(nonatomic, strong) UICollectionView *topPageSectionView;
//分页控制器
@property(nonatomic, strong) UIPageViewController *pageViewController;
@end

static NSString *const topCellID = @"top cell reuse identifier";
@implementation MMSearchResultsViewController

- (instancetype)initWithTerm:(NSString *)term{
    if (self = [super init]) {
        _term = term;
        _types = @[@"单曲",@"歌单",@"专辑",@"MV",@"歌手"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.


    [self.view addSubview:self.topPageSectionView];
    [MMSearchData.new searchDataForTemr:self.term completion:^(MMSearchData * _Nonnull searchData) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.searchData = searchData;
            [self.topPageSectionView reloadData];
        });
    }];
}

# pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.searchData.sectionCount;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MMSearchTopPageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:topCellID forIndexPath:indexPath];
    [cell.titleLabel setText:[self.searchData pageTitleForIndex:indexPath.row]];
    return cell;
}

# pragma mark - UICollectionViewDelegate
- (UICollectionView *)topPageSectionView{
    if (!_topPageSectionView) {
        UICollectionViewFlowLayout *layout =[[UICollectionViewFlowLayout alloc] init];
        CGFloat w = CGRectGetWidth(self.view.bounds)/4;
        CGFloat h = 44.0f;
        [layout setItemSize:CGSizeMake(w, h)];
        [layout setMinimumInteritemSpacing:1.0];
        [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];

        CGRect frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), h);
        _topPageSectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
        [_topPageSectionView registerClass:[MMSearchTopPageCell class] forCellWithReuseIdentifier:topCellID];
        [_topPageSectionView setContentInset:UIEdgeInsetsMake(0, 10, 0, 10)];
        [_topPageSectionView setBackgroundColor:UIColor.whiteColor];
        [_topPageSectionView setDelegate:self];
        [_topPageSectionView setDataSource:self];
    }
    return _topPageSectionView;
}



@end
