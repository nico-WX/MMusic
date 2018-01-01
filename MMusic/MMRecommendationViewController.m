//
//  RecommendationsCollectionViewController.m
//  MMusic
//
//  Created by Magician on 2017/11/23.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import <UIImageView+WebCache.h>

#import "MMRecommendationViewController.h"
#import "RecommendationsCell.h"
#import "MMRecommendationDetailViewController.h"

#import "PersonalizedRequestFactory.h"
#import "RequestFactory.h"
#import "NSObject+Tool.h"

#import "Recommendation.h"

extern NSString *const developerTokenUpdatedNotification;
extern NSString *const userTokenUpdatedNotification;
static NSString * const reuseIdentifier = @"recommemdationCell";

@interface MMRecommendationViewController ()<UICollectionViewDelegateFlowLayout>

@property(nonatomic,strong) NSArray<Recommendation*> *recommendationArray;  //默认推荐请求的所有数据
@property(nonatomic, strong) RequestFactory *requestFactory;                //普通请求工厂
@property(nonatomic, strong) PersonalizedRequestFactory *personalizedFactory;//个性化请求工厂

@end

@implementation MMRecommendationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    //监听userToken 更新通知
    [[NSNotificationCenter defaultCenter] addObserverForName:userTokenUpdatedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [self requestDefaultRecommendation];
    }];

    // Register cell classes
    [self.collectionView registerClass:[RecommendationsCell class] forCellWithReuseIdentifier:reuseIdentifier];
    [self.collectionView setShowsHorizontalScrollIndicator:NO];
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];

    //覆盖布局
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [self.collectionView setCollectionViewLayout:layout animated:YES];

    //请求默认个人推荐数据
    [self requestDefaultRecommendation];
}

/**请求默认推荐数据*/
- (void)requestDefaultRecommendation{
    //data url
    NSURLRequest *request = [self.personalizedFactory createRequestWithType:PersonalizedDefaultRecommendationsType resourceIds:@[]];

    [self dataTaskWithdRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *dict = [self serializationDataWithResponse:response data:data error:error];
        NSMutableArray *temp = [NSMutableArray array];
        for (NSDictionary *tempDict in [dict objectForKey:@"data"]) {
            //生成推荐对象
            Recommendation *recom = [Recommendation instanceWithDict:tempDict];
            [temp addObject:recom];
        }
        self.recommendationArray = temp;
        [self.collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [[NSNotificationCenter defaultCenter] removeObserver:self name:userTokenUpdatedNotification object:nil];
}


#pragma mark lazy
-(RequestFactory *)requestFactory{
    if (!_requestFactory) {
        _requestFactory = [RequestFactory requestFactory];
    }
    return _requestFactory;
}
-(PersonalizedRequestFactory *)personalizedFactory{
    if (!_personalizedFactory) {
        _personalizedFactory = [PersonalizedRequestFactory personalizedRequestFactory];
    }
    return _personalizedFactory;
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.recommendationArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RecommendationsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];

    [cell.contentView setBackgroundColor:[UIColor whiteColor]];
    cell.recommendation = [self.recommendationArray objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark <UICollectionViewDelegate>
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    MMRecommendationDetailViewController *detail = [[MMRecommendationDetailViewController alloc] init];
    //传入数据
    detail.recommendation = [self.recommendationArray objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:detail animated:YES];
}


#pragma mark <UICollectionViewDelegateFlowLayout>
//布局
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGSize size = collectionView.frame.size;
    return CGSizeMake(size.height-4,size.height-4);
    //return CGSizeMake(size.width-4, size.height-4);

}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    //UIEdgeInsetsMake(<#CGFloat top#>, <#CGFloat left#>, <#CGFloat bottom#>, <#CGFloat right#>)
    return UIEdgeInsetsMake(1, 10, 1,10);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 1;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 1;
}

@end
