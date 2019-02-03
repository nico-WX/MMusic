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

#import "ChartsSongCell.h"
#import "ChartsSubContentCell.h"

#import "ResponseRoot.h"
#import "Resource.h"

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

    Resource *res = self.responseRoot.data.firstObject;
    if ([res.type isEqualToString:@"songs"]) {
        [self.collectionView registerClass:[ChartsSongCell class] forCellWithReuseIdentifier:identifier];
        CGFloat h = 55;
        CGFloat w = CGRectGetWidth(self.view.bounds);
        [self.layout setItemSize:CGSizeMake(w, h)];
        [self.layout setMinimumInteritemSpacing:1];
    }else{
        [self.collectionView registerClass:[ChartsSubContentCell class] forCellWithReuseIdentifier:identifier];

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
- (void)configureCollectionCell:(UICollectionViewCell *)cell object:(Resource *)resource{
    if ([cell isKindOfClass:[ChartsSubContentCell class]]) {
        [((ChartsSubContentCell*)cell) setResource:resource];
    }
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    Resource *res = self.responseRoot.data.firstObject;

    if ([res.type isEqualToString:@"songs"]) {

    }else if ([res.type isEqualToString:@"music-videos"]){

    }else{
        Resource *res = [((ChartsSubContentCell*)cell) resource];
        ResourceDetailViewController *detailVC = [[ResourceDetailViewController alloc] initWithResource:res];
        [detailVC.navigationItem setLargeTitleDisplayMode:UINavigationItemLargeTitleDisplayModeNever];
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}
@end
