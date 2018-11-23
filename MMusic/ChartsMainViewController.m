//
//  ChartsMainViewController.m
//  MMusic
//
//  Copyright © 2018年 com.😈. All rights reserved.
//  pod and system
#import <Masonry.h>
#import <MJRefresh.h>

//Controller
#import "ChartsMainViewController.h"

//view  and cell
#import "ChartsMainCell.h"

//model and tool
#import "ChartsData.h"
#import "DataStoreKit.h"
#import "Resource.h"

@interface ChartsMainViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property(nonatomic, strong) NSArray<Chart*> *rowData;
@property(nonatomic, strong) UICollectionView *rowCollectionView; //每一行cell中包含一个视图控制器,及一个title

@property(nonatomic, strong)ChartsData *chartsData;
@end

static NSString *const reuseID = @"chartCell";
@implementation ChartsMainViewController


#pragma mark - cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;

    [self.view addSubview:self.rowCollectionView];
    [self.rowCollectionView setContentInset:UIEdgeInsetsMake(4, 4, 10, 4)];
    [self requestData];


}

- (void)viewDidLayoutSubviews{
    UIView *superView = self.view;
    [self.rowCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(superView);
    }];

    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)requestData {
    [ChartsData.new requestChartsWithCompletion:^(ChartsData * _Nonnull chartData) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.chartsData = chartData;
            [self.rowCollectionView reloadData];
        });
    }];
}

#pragma mark <UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.chartsData.count;

}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ChartsMainCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseID forIndexPath:indexPath];
    cell.chart = [self.chartsData chartWithIndexPath:indexPath];
    cell.navigationController = self.navigationController ; //传递导航控制器
    return cell;
}

#pragma mark <UICollectonViewDelegate>

#pragma mark <UICollectionViewDelegateFlowLayout>
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat w = CGRectGetWidth(collectionView.bounds)-(collectionView.contentInset.left+collectionView.contentInset.right);
    CGFloat h = 300;
    return CGSizeMake(w, h);
}

#pragma mark layz Load
- (UICollectionView *)rowCollectionView {
    if (!_rowCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        [layout setMinimumLineSpacing:20];

        _rowCollectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        [_rowCollectionView registerClass:[ChartsMainCell class] forCellWithReuseIdentifier:reuseID];
        [_rowCollectionView setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0]];

        _rowCollectionView.delegate = self;
        _rowCollectionView.dataSource = self;
    }
    return _rowCollectionView;
}



@end
