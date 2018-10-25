//
//  ChartsSubViiewController.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/10/24.
//  Copyright © 2018年 com.😈. All rights reserved.
//
#import <Masonry.h>

#import "ChartsSubViewController.h"
#import "DetailViewController.h"

#import "Chart.h"
#import "ResourceCell_V2.h"
#import "Album.h"
#import "Playlist.h"

@interface ChartsSubViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
@property(nonatomic, strong) UICollectionView *collectionView;
@end

static NSString * const reuseIdentifier = @"Cell";
@implementation ChartsSubViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.collectionView];
}

- (void)viewDidLayoutSubviews{

    [self.collectionView setFrame:self.view.bounds];
    [super viewDidLayoutSubviews];
}


#pragma mark <UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.chart.data.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ResourceCell_V2 *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];

    Resource *resource = [self.chart.data objectAtIndex: indexPath.row];
    


    Album *album = [Album instanceWithResource:resource];
    cell.album = album;

    return cell;
}

#pragma mark <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    Resource *resource = [self.chart.data objectAtIndex:indexPath.row];
    DetailViewController *detailVC = [[DetailViewController alloc] initWithResource:resource];
    [self.mainNavigatonController pushViewController:detailVC animated:YES];
}

#pragma mark <UICollectionViewDelegateFlowLayout>
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat h = CGRectGetHeight(collectionView.frame);
    CGFloat w = h-(h*0.2);
    return CGSizeMake(w, h);
}



#pragma mark setter/getter
-(UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];


        UICollectionView *view = [[UICollectionView alloc]  initWithFrame:self.view.bounds collectionViewLayout:layout];
        [view setDataSource:self];
        [view setDelegate:self];
        [view setBackgroundColor:UIColor.whiteColor];
        [view registerClass:[ResourceCell_V2 class] forCellWithReuseIdentifier:reuseIdentifier];

        _collectionView = view;
    }
    return _collectionView;
}

- (void)setChart:(Chart *)chart{
    if (_chart != chart) {
        _chart = chart;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    }
}
@end
