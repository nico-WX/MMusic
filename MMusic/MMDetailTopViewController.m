//
//  MMDetailTopViewController.m
//  MMusic
//
//  Created by Magician on 2017/12/6.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "MMDetailTopViewController.h"
#import "DetailTopViewCell.h"

@interface MMDetailTopViewController ()<UICollectionViewDelegateFlowLayout>
@property(nonatomic, strong) NSArray<Resource*> *resourceData;
@end

@implementation MMDetailTopViewController

static NSString * const reuseIdentifier = @"DetailTopViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[DetailTopViewCell class] forCellWithReuseIdentifier:reuseIdentifier];

    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    // Do any additional setup after loading the view.
    

    //重新覆盖布局
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [self.collectionView setCollectionViewLayout:layout animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setRecommendation:(Recommendation *)recommendation{
    if (_recommendation != recommendation) {
        _recommendation = recommendation;
    }
    self.resourceData = _recommendation.relationships.contents.data;
    if (!self.resourceData) {
        NSMutableArray *temp = [NSMutableArray array];
        for (Recommendation *subRecomm in _recommendation.relationships.recommendations.data) {
            for (Resource *resource in subRecomm.relationships.contents.data) {
                [temp addObject:resource];
            }
        }
        _resourceData = temp;
    }
}

#pragma mark <UICollectionViewDataSource>


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of items
    return self.resourceData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DetailTopViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.resource = [self.resourceData objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark <UICollectionViewDelegateFlowLayout>
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGRect frame = collectionView.frame;
    CGFloat cellH = frame.size.height - 2 ;
    CGFloat cellW = cellH;
    if (self.resourceData.count <= 2) {
        //居中
    }
    
    return CGSizeMake(cellW, cellH);
}

#pragma mark <UICollectionViewDelegate>

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    self.selectedData([self.resourceData objectAtIndex:indexPath.row]);
}
/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
