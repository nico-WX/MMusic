//
//  MMusic
//  Copyright © 2017年 com.😈. All rights reserved.
//


#import "RecommendationViewController.h"
#import "DetailViewController.h"

#import "RecommentationSectionView.h"
#import "ResourceCell.h"
#import "ResourceCell+ConfigureForResource.h"

//显示动画
#import "MMDetailPoppingAnimator.h"
#import "MMDetailPresentationController.h"

//data
#import "RecommendationDataSource.h"

#import "Resource.h"

@interface RecommendationViewController()<UICollectionViewDelegate,MMDetailViewControllerDelegate,UIViewControllerTransitioningDelegate,RecommendationDataSourceDelegate>

//内容视图
@property(nonatomic, strong) UICollectionView *collectionView;
//数据源
@property(nonatomic, strong) RecommendationDataSource *recommendationData;
//动画
@property(nonatomic, strong) MMDetailPresentationController *presentationController;
@property(nonatomic, strong) MMDetailPoppingAnimator *popupAnimator;
@end


@implementation RecommendationViewController
//reuse  identifier
static NSString *const sectionIdentifier = @"sectionView";
static NSString *const cellIdentifier = @"resourceCell";

#pragma mark - cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view setBackgroundColor:UIColor.whiteColor];
    [self.view addSubview:self.collectionView];

    self.popupAnimator = [[MMDetailPoppingAnimator alloc] init];
    self.recommendationData = [[RecommendationDataSource alloc] initWithCollectionView:self.collectionView identifier:cellIdentifier sectionIdentifier:sectionIdentifier delegate:self];
}
- (void)tokenDidUpdate{
    NSLog(@"刷新数据源");
    [self.recommendationData reloadDataSource];
}


- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];

    [_collectionView setFrame:self.view.bounds];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - 数据源代理

- (void)configureCell:(ResourceCell*)cell item:(Resource*)item{
    [cell setResource:item];
}

- (void)configureSupplementaryElement:(UICollectionReusableView *)reusableView object:(NSString *)title{
    if ([reusableView isKindOfClass:[RecommentationSectionView class]]) {
        [((RecommentationSectionView*)reusableView).titleLabel setText:title];
    }
}

#pragma mark - <UICollectionViewDelegate>
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    ResourceCell *cell = (ResourceCell*)[collectionView cellForItemAtIndexPath:indexPath];
    Resource *resource = [self.recommendationData selectedResourceAtIndexPath:indexPath];

    DetailViewController *detail = [[DetailViewController alloc] initWithResource:resource];

    //显示动画
    [detail setDisMissDelegate:self];
    [detail setTransitioningDelegate:self];
    [detail setModalPresentationStyle:UIModalPresentationCustom];

    [detail.titleLabel setText:cell.titleLabel.text];
    [detail.imageView setImage:cell.imageView.image];

    //动画相关
    CGRect startFram = cell.frame;
    startFram.origin.y -= collectionView.contentOffset.y; // 减去滚动偏移,动画消除动画弹出时的初始位置太大造成的晃动;
    [self.popupAnimator setStartFrame:startFram];
    [self presentViewController:detail animated:YES completion:nil];
}
#pragma mark - <DetailViewControllerDelegate>
- (void)detailViewControllerDidDismiss:(DetailViewController *)detailVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - <UIViewControllerTransitioningDelegate>
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    [self.popupAnimator setPresenting:YES];
    return self.popupAnimator;
}
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    [self.popupAnimator setPresenting:NO];
    return self.popupAnimator;
}
-(UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source{
    self.presentationController =[[MMDetailPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
    return self.presentationController;
}



#pragma mark -  getter / setter
-(UICollectionView *)collectionView{
    if (!_collectionView) {

        UIEdgeInsets insets = UIEdgeInsetsMake(0, 8, 0, 8);
        CGFloat spacing = insets.left;

        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];

        //两列  计算size
        CGFloat w = CGRectGetWidth(self.view.bounds);
        w = (w - insets.left*3)/2;
        CGFloat h = w+30;
        CGSize itemSize = CGSizeMake(w, h);
        CGSize headerSize = CGSizeMake(CGRectGetWidth(self.view.bounds),44.0f);

        [layout setItemSize:itemSize];
        [layout setHeaderReferenceSize:headerSize];
        [layout setMinimumLineSpacing:spacing*2];
        [layout setMinimumInteritemSpacing:spacing/2];
        [layout setSectionInset:insets]; //cell 与头尾间距
        [layout setScrollDirection:UICollectionViewScrollDirectionVertical];

        //集合视图对象
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        [_collectionView registerClass:[ResourceCell class] forCellWithReuseIdentifier:cellIdentifier];
        [_collectionView registerClass:[RecommentationSectionView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:sectionIdentifier];

        [_collectionView setBackgroundColor:[UIColor whiteColor]];
        [_collectionView setDelegate: self];
    }
    return _collectionView;
}

@end
