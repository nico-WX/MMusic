//
//  TodayCollectionViewController.m
//  MMusic
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import <JGProgressHUD.h>
#import <MJRefresh.h>
#import <Masonry.h>

#import "RecommendationViewController.h"
#import "MMDetailViewController.h"
#import "MMTabBarController.h"

#import "RecommentationSectionView.h"
#import "ResourceCell.h"

//显示动画
#import "MMDetailPoppingAnimator.h"
#import "MMDetailPresentationController.h"

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

    //底部偏移量(底部浮动播放器窗口)
    if ([self.tabBarController isKindOfClass:[MMTabBarController class]]) {
        MMTabBarController *tabBarController = (MMTabBarController*)self.tabBarController;
        CGFloat bottomInset = CGRectGetHeight(self.view.frame) - CGRectGetMinY(tabBarController.popFrame);
        [self.collectionView setContentInset:UIEdgeInsetsMake(0, 0, bottomInset, 0)];
    }

    self.popupAnimator = [[MMDetailPoppingAnimator alloc] init];
    self.recommendationData = [[RecommendationDataSource alloc] initWithCollectionView:self.collectionView cellIdentifier:cellIdentifier sectionIdentifier:sectionIdentifier delegate:self];


    if ([self.navigationController.navigationBar isHidden]) {
        [self.collectionView.mj_header setIgnoredScrollViewContentInsetTop:20];  //调整顶部距离
    }
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - 数据源代理
- (void)configureCell:(UICollectionViewCell *)cell object:(Resource *)resource{
    if ([cell isKindOfClass:[ResourceCell class]]) {
        [((ResourceCell*)cell) setResource:resource];
    }
}
- (void)configureSupplementaryElement:(UICollectionReusableView *)reusableView object:(NSString *)title{
    if ([reusableView isKindOfClass:[RecommentationSectionView class]]) {
        [((RecommentationSectionView*)reusableView).titleLabel setText:title];
    }
}


#pragma mark - <UICollectionViewDelegate>
// 选中,  呈现专辑或者播放列表 歌曲信息
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    ResourceCell *cell = (ResourceCell*)[collectionView cellForItemAtIndexPath:indexPath];
    MMDetailViewController *detail = [[MMDetailViewController alloc] initWithResource:cell.resource];

    [detail setDisMissDelegate:self];
    [detail setTransitioningDelegate:self];
    [detail setModalPresentationStyle:UIModalPresentationCustom];

    [detail.titleLabel setText:cell.titleLabel.text];
    [detail.imageView setImage:cell.imageView.image];

    CGRect startFram = cell.frame;
    startFram.origin.y -= collectionView.contentOffset.y; // 减去滚动偏移,动画消除动画弹出时的初始位置太大造成的晃动;

    [self.popupAnimator setStartFrame:startFram];
    [self presentViewController:detail animated:YES completion:nil];
}
#pragma mark - <DetailViewControllerDelegate>
- (void)detailViewControllerDidDismiss:(MMDetailViewController *)detailVC{
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


#pragma mark - lazy load
-(UICollectionView *)collectionView{
    if (!_collectionView) {

        //布局对象
        UICollectionViewFlowLayout *layout = ({

            UICollectionViewFlowLayout *flow = [UICollectionViewFlowLayout new];
            //两列
            CGFloat spacing = 8.0f;
            CGFloat cw = (CGRectGetWidth(self.view.frame) - spacing*3)/2;
            CGFloat ch = cw+32;
            CGSize itemSize = CGSizeMake(cw, ch);
            CGSize headerSize = CGSizeMake(CGRectGetWidth(self.view.bounds),44.0f);

            [flow setItemSize:itemSize];
            [flow setHeaderReferenceSize:headerSize];
            [flow setMinimumLineSpacing:spacing*2];
            [flow setMinimumInteritemSpacing:spacing];
            [flow setSectionInset:UIEdgeInsetsMake(0, spacing, spacing, spacing)]; //cell 与头尾间距
            [flow setScrollDirection:UICollectionViewScrollDirectionVertical];

            flow;
        });

        //集合视图对象
        _collectionView = ({
            UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
            [collectionView registerClass:[ResourceCell class] forCellWithReuseIdentifier:cellIdentifier];
            [collectionView registerClass:[RecommentationSectionView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:sectionIdentifier];
            [collectionView setBackgroundColor:[UIColor whiteColor]];
            [collectionView setDelegate: self];
            collectionView;
        });
    }
    return _collectionView;
}
@end
