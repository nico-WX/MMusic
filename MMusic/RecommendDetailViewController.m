//
//  RecommendDetailViewController.m
//  MMusic
//
//  Created by Magician on 2017/12/27.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "RecommendDetailViewController.h"
#import "RecommendDetailCell.h"
#import "ResourceDetailViewController.h"

#import "Resource.h"

@interface RecommendDetailViewController ()<UICollectionViewDataSource>
@end

@implementation RecommendDetailViewController

static NSString *reuseIdentifier = @"cellReuseIdentifier";
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    [self.collectionView registerClass:[RecommendDetailCell class] forCellWithReuseIdentifier:reuseIdentifier];

    [self resetLayout];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark 布局
-(void)resetLayout{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [self.collectionView setCollectionViewLayout:layout animated:YES];

    CGSize size = self.collectionView.frame.size;
    CGFloat w = size.width - 4;
    CGFloat h = w *0.4;
    [layout setItemSize:CGSizeMake(w, h)];

}


#pragma mark <UICollectionViewDataSource>
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.data count];
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    RecommendDetailCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.resource = [self.data objectAtIndex:indexPath.row];
    return  cell;
}
#pragma mark <UICollectionViewDelegate>
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    RecommendDetailCell *cell = [collectionView cellForItemAtIndexPath:indexPath];

    ResourceDetailViewController *detail = [[ResourceDetailViewController alloc] init];
    detail.resource = cell.resource;
    [self.navigationController pushViewController:detail animated:YES];
    
}
@end
