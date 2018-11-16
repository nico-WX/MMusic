//
//  TodayCollectionViewController.m
//  MMusic
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import <MJRefresh.h>
#import <Masonry.h>

#import "RecommendationViewController.h"
#import "MMDetailViewController.h"

#import "TodaySectionView.h"
#import "ResourceCell.h"
#import "ResourceCell_V2.h"

#import "MMPopupAnimator.h"
#import "MMPresentationController.h"

#import "Resource.h"
#import "DataStoreKit.h"

@interface RecommendationViewController()<UICollectionViewDelegate,UICollectionViewDataSource,
UICollectionViewDataSourcePrefetching,MMDetailViewControllerDelegate,UIViewControllerTransitioningDelegate>


@property(nonatomic, strong) UICollectionView *collectionView;
//json 结构
@property(nonatomic, strong) NSArray<NSDictionary<NSString*,NSArray<Resource*>*>*> *allData;

@property(nonatomic, strong)MMPresentationController *presentationController;
@property(nonatomic, strong)MMPopupAnimator *popupAnimator;
@end


@implementation RecommendationViewController
//reuse  identifier
static NSString *const sectionIdentifier = @"sectionView";
static NSString *const cellIdentifier = @"resourceCell";

#pragma mark - cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    _popupAnimator = [MMPopupAnimator new];

    [self.view setBackgroundColor:UIColor.whiteColor];
    [self.view addSubview:self.collectionView];

    [self requestData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma  mark - 请求数据 和解析JSON
- (void)requestData {
    //加载数据
    [DataStore.new requestDefaultRecommendationWithCompletion:^(NSArray<NSDictionary<NSString *,NSArray<Resource *> *> *> * _Nonnull array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView.mj_header endRefreshing];
            self.allData = array;
            [self.collectionView reloadData];
        });
    }];
}

#pragma mark - <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.allData.count;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.allData objectAtIndex:section].allValues.firstObject.count;
}

//cell
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    NSDictionary<NSString*,NSArray<Resource*>*> *dict = [self.allData objectAtIndex:indexPath.section]; //节数据
    Resource* resource = [dict.allValues.firstObject objectAtIndex:indexPath.row];                      //row数据

    //dequeue cell
    ResourceCell_V2 *cell = (ResourceCell_V2*)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    [cell setResource:resource];
    return cell;
}

//头尾
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    //节头
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        NSString *title = [self.allData objectAtIndex:indexPath.section].allKeys.firstObject;
        TodaySectionView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:sectionIdentifier forIndexPath:indexPath];
        [header.titleLabel setText:title];
        return header;
    }
    return nil;
}

#pragma mark - <UICollectionViewDelegate>
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    ResourceCell_V2 *cell = (ResourceCell_V2*)[collectionView cellForItemAtIndexPath:indexPath];
    MMDetailViewController *detail = [[MMDetailViewController alloc] initWithResource:cell.resource];

    [detail setDisMissDelegate:self];
    [detail setTransitioningDelegate:self];
    [detail setModalPresentationStyle:UIModalPresentationCustom];

    [detail.titleLabel setText:cell.titleLabel.text];
    [detail.imageView setImage:cell.imageView.image];

    [self.popupAnimator setStartFrame:cell.frame];
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
    self.presentationController =[[MMPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
    return self.presentationController;
}

#pragma mark - <UICollectionViewDataSourcePrefetching>  预取数据
- (void)collectionView:(UICollectionView *)collectionView prefetchItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths{
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

        //集合对象
        _collectionView = ({

            UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
            [collectionView registerClass:[ResourceCell_V2 class] forCellWithReuseIdentifier:cellIdentifier];
            [collectionView registerClass:[TodaySectionView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:sectionIdentifier];
            [collectionView setBackgroundColor:[UIColor whiteColor]];
            [collectionView setDataSource:self];
            [collectionView setDelegate: self];
            //刷新控件
            [collectionView setMj_header:[MJRefreshNormalHeader headerWithRefreshingBlock:^{
                UIImpactFeedbackGenerator *impact = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleHeavy];
                [impact impactOccurred];
                [self requestData];
            }]];
            [collectionView.mj_header setIgnoredScrollViewContentInsetTop:20];  //调整顶部距离

            collectionView;
        });
    }
    return _collectionView;
}


@end
